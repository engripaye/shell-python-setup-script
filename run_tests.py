import sys
import subprocess


def main():
    args = ["pytest", "-q"]
    print("Running", " ".join(args))
    rc = subprocess.call(args)
    sys.exit(rc)


if __name__ == "__main__":
    main()
