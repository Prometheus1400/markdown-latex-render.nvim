import argparse
from pathlib import Path

import matplotlib.pyplot as plt

plt.rcParams["mathtext.fontset"] = "cm"
plt.rcParams["font.weight"] = "bold"


def try_generate_image(
    latex: str,
    path: str,
    width: int,
    fg: str | None = None,
    bg: str | None = None,
    transparent: bool = False,
    usetext: bool = True,
) -> bool:
    try:
        # will dynamically create the height based on the number of lines to render
        # but width should be passed as an argument (width of window)
        fig = plt.figure(
            figsize=(width, max(latex.count("\n") // 2.5, 1)), dpi=400, facecolor=bg
        )
        fig.text(
            x=0.5,
            y=0.5,
            s=latex,
            parse_math=True,
            horizontalalignment="center",
            verticalalignment="center",
            fontsize=14,
            color=fg,
            usetex=usetext,
        )

        plt.savefig(path, format="png", transparent=transparent)
        return True
    except Exception as e:
        return False


def main():
    parser = argparse.ArgumentParser(description="Convert latex string into image.")
    parser.add_argument("latex", type=str, help="input latex string")
    parser.add_argument(
        "-o", type=Path, help="output path/name of generated image", required=True
    )
    parser.add_argument("-bg", type=str, help="hex background color", required=False)
    parser.add_argument("-fg", type=str, help="hex foreground color", required=False)
    parser.add_argument(
        "-t", action="store_true", help="enable transparency", required=False
    )
    parser.add_argument(
        "-w",
        type=int,
        help="width of image to generate in inches",
        required=False,
        default=4,
    )
    parser.add_argument(
        "--usetex", action="store_true", help="use latex toolchain", required=False
    )
    parser.add_argument("--preamble", type=str, help="text packages to use", required=False)

    args = parser.parse_args()
    latex: str = args.latex
    output_path: Path = args.o
    fg: str = args.fg
    bg: str = args.bg
    width: int = args.w
    usetex: bool = args.usetex
    preamble: str = args.preamble

    if not usetex:
        latex = f"${latex.strip().strip("$").strip()}$"
        if latex.count("\n") > 0:
            print(f"could not generate image from latex: {latex}")
            exit(1)
    else:
        latex=latex.strip("$").strip()
        if r"\begin" not in latex:
            latex = f"${latex}$"
        else:
            latex = latex.replace("\n", "")

        if preamble:
            plt.rcParams["text.latex.preamble"] = preamble

    if not try_generate_image(
        latex,
        str(output_path),
        width=width,
        fg=fg,
        bg=bg,
        transparent=args.t,
        usetext=usetex,
    ):
        print(f"could not generate image from latex: {latex}")
        exit(1)


if __name__ == "__main__":
    main()
