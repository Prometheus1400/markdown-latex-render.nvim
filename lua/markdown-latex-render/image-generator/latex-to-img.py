import argparse
import re

import matplotlib.pyplot as plt

from pathlib import Path

plt.rcParams["mathtext.fontset"] = "cm"  # Font changed to Computer Modern
plt.rcParams["font.weight"] = "bold"


def is_output_png(path: str) -> bool:
    pattern = r".*\.png$"
    return bool(re.match(pattern, path))


def try_generate_image(latex_lines: list[str], path: str, fg: str | None = None, bg : str | None = None, transparent: bool = False, width: int = 4) -> bool:
    try:
        # will dynamically create the height based on the number of lines to render
        # but width should be passed as an argument (width of window)
        fig = plt.figure(figsize=(width, max(len(latex_lines) // 2.5, 1)), dpi=400, facecolor=bg)
        fig.text(
            x=0.5,
            y=0.5,
            s="\n".join(latex_lines),
            horizontalalignment="center",
            verticalalignment="center",
            fontsize=14,
            color=fg
        )
        plt.savefig(path, format="png", transparent=transparent)
        return True
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser(description="Convert latex string into image.")
    parser.add_argument("latex", type=str, help="input latex string")
    parser.add_argument("-o", type=Path, help="output path/name of generated image", required=True)
    parser.add_argument("-bg", type=str, help="hex background color", required=False)
    parser.add_argument("-fg", type=str, help="hex foreground color", required=False)
    parser.add_argument('-t', action='store_true', help='enable transparency', required=False)
    parser.add_argument('-w', type=int, help='width of image to generate in inches', required=False, default=4)

    args = parser.parse_args()

    latex:str = args.latex
    output_path:Path = args.o
    fg, bg = args.fg, args.bg
    width:int = args.w
    latex_lines = []
    for line in latex.splitlines():
        if line.endswith("\\\\"):
            latex_lines.append(f"${line[:-2].strip()}$")
        else:
            latex_lines.append(f"${line}$")

    if not try_generate_image(latex_lines, str(output_path), fg=fg, bg=bg, transparent=args.t, width=width):
        print(f"could not generate image from latex: {latex}")
        exit(1)


if __name__ == "__main__":
    main()
