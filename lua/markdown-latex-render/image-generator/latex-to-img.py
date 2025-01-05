import argparse
from pathlib import Path

import matplotlib.pyplot as plt

plt.rcParams["mathtext.fontset"] = "cm"
plt.rcParams["font.weight"] = "bold"


def generate_image(
    latex: str,
    path: str,
    fontsize: int,
    ppi: int,
    fg: str | None = None,
    bg: str | None = None,
    transparent: bool = False,
    usetex: bool = False,
):
    # will dynamically create the height based on the number of lines to render
    # but width should be passed as an argument (width of window)
    fig = plt.figure(figsize=(32, 26), dpi=ppi, facecolor=bg)
    fig.text(
        x=0.5,
        y=0.5,
        s=latex,
        parse_math=True,
        horizontalalignment="center",
        verticalalignment="center",
        fontsize=fontsize,
        color=fg,
        usetex=usetex,
    )
    plt.savefig(path, format="png", bbox_inches="tight", transparent=transparent)


def main():
    parser = argparse.ArgumentParser(description="Convert latex string into image.")
    parser.add_argument("latex", type=str, help="input latex string")
    parser.add_argument(
        "-o", type=Path, help="output path/name of generated image", required=True
    )
    parser.add_argument("--ppi", type=int, help="ppi of display", required=True)
    parser.add_argument(
        "--fontsize", type=int, help="font size of latex", required=True
    )
    parser.add_argument("-bg", type=str, help="hex background color", required=False)
    parser.add_argument("-fg", type=str, help="hex foreground color", required=False)
    parser.add_argument(
        "-t", action="store_true", help="enable transparency", required=False
    )
    parser.add_argument(
        "--usetex", action="store_true", help="use latex toolchain", required=False
    )
    parser.add_argument(
        "--preamble", type=str, help="text packages to use", required=False
    )

    try:
        args = parser.parse_args()
        latex: str = args.latex
        output_path: Path = args.o
        fontsize: int = args.fontsize
        ppi: int = args.ppi
        fg: str = args.fg
        bg: str = args.bg
        usetex: bool = args.usetex
        preamble: str = args.preamble

        if not usetex:
            latex = f"${latex.strip().strip("$").strip()}$"
            if latex.count("\n") > 0:
                raise RuntimeError(f"multiline mathtex not allowed")
        else:
            latex = latex.strip("$").strip()
            if r"\begin" not in latex:
                latex = f"${latex}$"
            else:
                latex = latex.replace("\n", "")

            if preamble:
                plt.rcParams["text.latex.preamble"] = preamble

        generate_image(
            latex=latex,
            path=str(output_path),
            fontsize=fontsize,
            ppi=ppi,
            fg=fg,
            bg=bg,
            transparent=args.t,
            usetex=usetex,
        )
    except Exception as e:
        print(f"could not generate image from latex: '{latex}' with error {e}")
        exit(1)


if __name__ == "__main__":
    main()
