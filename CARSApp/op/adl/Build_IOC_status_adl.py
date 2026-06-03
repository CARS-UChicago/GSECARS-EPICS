#!/usr/bin/python

from __future__ import annotations

import json
import sys
from dataclasses import dataclass, field
from typing import List


# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

PREFIX = "Beamline"
BASENAME = "_IOC_status"
IOC_STATUS_FILE = "IOC_status.adl"

# Max screen size in pixels
MAX_SCREEN_WIDTH = 1920
MAX_SCREEN_HEIGHT = 1000

# Page margins and spacing
LEFT_MARGIN = 5
TOP_MARGIN = 5
RIGHT_MARGIN = 5
BOTTOM_MARGIN = 5
COLUMN_GAP = 10
GROUP_GAP_Y = 10

# Group geometry taken from IOC_Status_test.adl
GROUP_WIDTH = 610
GROUP_TITLE_Y_OFFSET = 5
GROUP_TITLE_HEIGHT = 25

HEADER_Y_TOP = 40
HEADER_Y_BOTTOM = 60

FIRST_ROW_Y_OFFSET = 85
ROW_STEP = 25

EMBED_X_OFFSET = 5
EMBED_WIDTH = 640
EMBED_HEIGHT = 21

# Colors from example ADL
DISPLAY_CLR = 14
DISPLAY_BCLR = 4
TITLE_CLR = 53
HEADER_CLR = 14
RECT_CLR = 14

DISPLAY_VERSION = "030117"


# -----------------------------------------------------------------------------
# Data model
# -----------------------------------------------------------------------------

@dataclass
class IOC:
    name: str
    prefix: str
    description: str = ""


@dataclass
class Group:
    name: str
    iocs: List[IOC] = field(default_factory=list)

    @property
    def height(self) -> int:
        """
        Match example:
            1 IOC -> 115
            2 IOCs -> 140
            3 IOCs -> 165
        Formula:
            height = 90 + N * 25
        """
        return 90 + len(self.iocs) * ROW_STEP


@dataclass
class PlacedGroup:
    group: Group
    x: int
    y: int


@dataclass
class Page:
    number: int
    groups: List[PlacedGroup] = field(default_factory=list)
    width: int = 0
    height: int = 0


# -----------------------------------------------------------------------------
# JSON parsing
# -----------------------------------------------------------------------------

def normalize_prefix(prefix: str) -> str:
    """
    Parent IOC_Status_test.adl passes PREFIX without trailing colon:
        PREFIX=13IDA
    while JSON contains:
        13IDA:
    """
    return prefix[:-1] if prefix.endswith(":") else prefix


def load_groups(json_path: str) -> List[Group]:
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    groups_data = data.get("Groups")
    if not isinstance(groups_data, list):
        raise ValueError('JSON must contain top-level key "Groups" with a list.')

    groups: List[Group] = []

    for g in groups_data:
        group_name = g.get("Name", "Unnamed Group")
        ioc_data = g.get("IOCs", [])
        if not isinstance(ioc_data, list):
            raise ValueError(f'Group "{group_name}" has invalid "IOCs" value.')

        iocs: List[IOC] = []
        for item in ioc_data:
            prefix = item.get("Prefix")
            if not prefix:
                raise ValueError(f'IOC in group "{group_name}" is missing "Prefix".')

            iocs.append(
                IOC(
                    name=item.get("Name", normalize_prefix(prefix)),
                    prefix=normalize_prefix(prefix),
                    description=item.get("Description", ""),
                )
            )

        groups.append(Group(name=group_name, iocs=iocs))

    return groups


# -----------------------------------------------------------------------------
# Layout
# -----------------------------------------------------------------------------

def layout_groups(groups: List[Group]) -> List[Page]:
    pages: List[Page] = []
    page = Page(number=1)

    x = LEFT_MARGIN
    y = TOP_MARGIN

    max_used_width = 0
    max_used_height = 0

    for group in groups:
        gh = group.height

        # Next column if this group won't fit vertically
        if y > TOP_MARGIN and (y + gh + BOTTOM_MARGIN > MAX_SCREEN_HEIGHT):
            x += GROUP_WIDTH + COLUMN_GAP
            y = TOP_MARGIN

        # Next page if new column won't fit horizontally
        if x + GROUP_WIDTH + RIGHT_MARGIN > MAX_SCREEN_WIDTH:
            page.width = max_used_width
            page.height = max_used_height
            pages.append(page)

            page = Page(number=len(pages) + 1)
            x = LEFT_MARGIN
            y = TOP_MARGIN
            max_used_width = 0
            max_used_height = 0

        page.groups.append(PlacedGroup(group=group, x=x, y=y))

        max_used_width = max(max_used_width, x + GROUP_WIDTH + RIGHT_MARGIN)
        max_used_height = max(max_used_height, y + gh + BOTTOM_MARGIN)

        y += gh + GROUP_GAP_Y

    if page.groups:
        page.width = max_used_width
        page.height = max_used_height
        pages.append(page)

    return pages


# -----------------------------------------------------------------------------
# ADL blocks
# -----------------------------------------------------------------------------

COLOR_MAP_BLOCK = """"color map" {
        ncolors=65
        colors {
                ffffff,
                ececec,
                dadada,
                c8c8c8,
                bbbbbb,
                aeaeae,
                9e9e9e,
                919191,
                858585,
                787878,
                696969,
                5a5a5a,
                464646,
                2d2d2d,
                000000,
                00d800,
                1ebb00,
                339900,
                2d7f00,
                216c00,
                fd0000,
                de1309,
                be190b,
                a01207,
                820400,
                5893ff,
                597ee1,
                4b6ec7,
                3a5eab,
                27548d,
                fbf34a,
                f9da3c,
                eeb62b,
                e19015,
                cd6100,
                ffb0ff,
                d67fe2,
                ae4ebc,
                8b1a96,
                610a75,
                a4aaff,
                8793e2,
                6a73c1,
                4d52a4,
                343386,
                c7bb6d,
                b79d5c,
                a47e3c,
                7d5627,
                58340f,
                99ffff,
                73dfff,
                4ea5f9,
                2a63e4,
                0a00b8,
                ebf1b5,
                d4db9d,
                bbc187,
                a6a462,
                8b8239,
                73ff6b,
                52da3b,
                3cb420,
                289315,
                1a7309,
        }
}
"""


def adl_header(title: str, width: int, height: int) -> str:
    return f"""file {{
        name="{title}"
        version={DISPLAY_VERSION}
}}
display {{
        object {{
                x=180
                y=130
                width={width}
                height={height}
        }}
        clr={DISPLAY_CLR}
        bclr={DISPLAY_BCLR}
        cmap=""
        gridSpacing=5
        gridOn=0
        snapToGrid=0
}}
{COLOR_MAP_BLOCK}"""


def adl_text(
    x: int,
    y: int,
    width: int,
    height: int,
    clr: int,
    text: str,
    align: str | None = None,
) -> str:
    safe = text.replace('"', '\\"')
    s = f"""text {{
        object {{
                x={x}
                y={y}
                width={width}
                height={height}
        }}
        "basic attribute" {{
                clr={clr}
        }}
        textix="{safe}"
"""
    if align is not None:
        s += f"""        align={align}
"""
    s += """}
"""
    return s


def adl_rectangle(x: int, y: int, width: int, height: int, clr: int) -> str:
    return f"""rectangle {{
        object {{
                x={x}
                y={y}
                width={width}
                height={height}
        }}
        "basic attribute" {{
                clr={clr}
                fill="outline"
        }}
}}
"""


def adl_composite_two_line_header(
    x: int,
    y: int,
    width: int,
    top_x: int,
    top_width: int,
    top_text: str,
    bottom_text: str,
) -> str:
    return f"""composite {{
        object {{
                x={x}
                y={y}
                width={width}
                height=40
        }}
        "composite name"=""
        children {{
                text {{
                        object {{
                                x={top_x}
                                y={y}
                                width={top_width}
                                height=20
                        }}
                        "basic attribute" {{
                                clr={HEADER_CLR}
                        }}
                        textix="{top_text}"
                }}
                text {{
                        object {{
                                x={x}
                                y={y + 20}
                                width={width}
                                height=20
                        }}
                        "basic attribute" {{
                                clr={HEADER_CLR}
                        }}
                        textix="{bottom_text}"
                }}
        }}
}}
"""


def adl_embedded_ioc(x: int, y: int, prefix: str) -> str:
    return f"""composite {{
        object {{
                x={x}
                y={y}
                width={EMBED_WIDTH}
                height={EMBED_HEIGHT}
        }}
        "composite name"=""
        "composite file"="{IOC_STATUS_FILE};PREFIX={prefix}"
}}
"""


# -----------------------------------------------------------------------------
# Group rendering
# -----------------------------------------------------------------------------

def emit_group(group: Group, x: int, y: int) -> str:
    parts: List[str] = []

    # Title
    title_width = 120
    title_x = x + (GROUP_WIDTH - title_width) // 2
    parts.append(
        adl_text(
            title_x,
            y + GROUP_TITLE_Y_OFFSET,
            title_width,
            GROUP_TITLE_HEIGHT,
            TITLE_CLR,
            group.name,
            align='"horiz. centered"',
        )
    )

    # One-line headers
    parts.append(adl_text(x + 10,  y + HEADER_Y_BOTTOM, 100, 20, HEADER_CLR, "IOC prefix"))
    parts.append(adl_text(x + 165, y + HEADER_Y_BOTTOM, 40,  20, HEADER_CLR, "Host"))
    parts.append(adl_text(x + 265, y + HEADER_Y_BOTTOM, 60,  20, HEADER_CLR, "Uptime"))

    # Two-line headers matching example geometry
    parts.append(
        adl_composite_two_line_header(
            x=x + 345,
            y=y + HEADER_Y_TOP,
            width=60,
            top_x=x + 350,
            top_width=50,
            top_text="CA PV",
            bottom_text="conns.",
        )
    )

    parts.append(adl_text(x + 430, y + HEADER_Y_TOP,    70, 20, HEADER_CLR, "IOC"))
    parts.append(adl_text(x + 415, y + HEADER_Y_BOTTOM, 40, 20, HEADER_CLR, "CPU %"))

    parts.append(
        adl_composite_two_line_header(
            x=x + 490,
            y=y + HEADER_Y_TOP,
            width=60,
            top_x=x + 470,
            top_width=40,
            top_text="Mem. free",
            bottom_text="GiB",
        )
    )

    # Embedded IOC rows
    row_y = y + FIRST_ROW_Y_OFFSET
    for ioc in group.iocs:
        parts.append(adl_embedded_ioc(x + EMBED_X_OFFSET, row_y, ioc.prefix))
        row_y += ROW_STEP

    # Group outline
    parts.append(adl_rectangle(x, y, GROUP_WIDTH, group.height, RECT_CLR))

    return "".join(parts)


def generate_page(page: Page, title: str) -> str:
    parts = [adl_header(title, page.width, page.height)]
    for placed in page.groups:
        parts.append(emit_group(placed.group, placed.x, placed.y))
    return "".join(parts)


# -----------------------------------------------------------------------------
# Output
# -----------------------------------------------------------------------------

def write_pages(pages: List[Page]) -> List[str]:
    filenames: List[str] = []

    for i, page in enumerate(pages, start=1):
        if i == 1:
            filename = f"{PREFIX + BASENAME}.adl"
        else:
            filename = f"{PREFIX + BASENAME}_{i}.adl"

        with open(filename, "w", encoding="utf-8") as f:
            f.write(generate_page(page, filename))

        filenames.append(filename)

    return filenames


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def main() -> int:
    global PREFIX
    PREFIX = sys.argv[1] if len(sys.argv) > 1 else PREFIX
    json_path = PREFIX + BASENAME + ".json"

    try:
        groups = load_groups(json_path)
        if not groups:
            raise ValueError("No groups found in JSON input.")

        pages = layout_groups(groups)
        written = write_pages(pages)

        print("Generated ADL files:")
        for filename in written:
            print(f"  {filename}")

        return 0

    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
