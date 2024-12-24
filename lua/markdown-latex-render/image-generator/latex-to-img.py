import argparse
import re

import matplotlib
import matplotlib.pyplot as plt

matplotlib.rcParams["mathtext.fontset"] = "cm"  # Font changed to Computer Modern


def is_output_png(path: str) -> bool:
    pattern = r".*\.png$"
    return bool(re.match(pattern, path))


def try_generate_image(latex: str, path: str, fg: str | None = None, bg : str | None = None, transparent: bool = False) -> bool:
    try:
        fig = plt.figure(figsize=(4, 1), dpi=400, facecolor=bg)
        fig.text(
            x=0.5,
            y=0.5,
            s=latex,
            horizontalalignment="center",
            verticalalignment="center",
            fontsize=16,
            color=fg
        )
        plt.savefig(path, format="png", transparent=transparent)
        return True
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser(description="Convert latex string into image.")
    parser.add_argument("latex", type=str, help="input latex string")
    parser.add_argument(
        "-o", type=str, help="output path/name of generated image", required=True
    )
    parser.add_argument(
        "-bg", type=str, help="hex background color", required=False
    )
    parser.add_argument(
        "-fg", type=str, help="hex foreground color", required=False
    )
    parser.add_argument('-t', action='store_true', help='enable transparency', required=False)

    args = parser.parse_args()

    latex:str = args.latex
    output_path = args.o
    fg, bg = args.fg, args.bg
    if not is_output_png(output_path):
        print("output path must be a 'png' file")
        exit(1)
    latex = "\n".join(f"${latex_line}$" for latex_line in latex.splitlines())

    if not try_generate_image(latex, output_path, fg=fg, bg=bg, transparent=args.t):
        print(f"could not generate image from latex: {latex}")
        exit(1)


if __name__ == "__main__":
    main()
