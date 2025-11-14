#!/usr/bin/env python3
import sys
import glob
from lxml import etree


def validate_xml_files():
    files = glob.glob("repo-specs/**/*.xml", recursive=True)
    errors = []

    for filepath in files:
        try:
            parser = etree.XMLParser()
            etree.parse(filepath, parser)
            print(f"✓ {filepath}")
        except etree.XMLSyntaxError as e:
            error_msg = f"{filepath}:{e.lineno} - {e.msg}"
            errors.append(error_msg)
            print(f"✗ {error_msg}")
        except Exception as e:
            error_msg = f"{filepath} - {str(e)}"
            errors.append(error_msg)
            print(f"✗ {error_msg}")

    if errors:
        print(f"\n{len(errors)} validation error(s) found")
        sys.exit(1)
    else:
        print(f"\n{len(files)} file(s) validated successfully")
        sys.exit(0)


if __name__ == "__main__":
    validate_xml_files()
