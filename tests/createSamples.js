const blns = require("blns")
const CODE128 = require("jsbarcode").getModule("CODE128")

main()

function main() {
  const samples = blns
    .map(
      (v) =>
        "    ( " +
        JSON.stringify(v).replace(/\\u([0-9a-z]){4}/g, "\\u{$1}") +
        ", " +
        encode(v) +
        " )"
    )
    .join(",\n")

  const output = [
    "module Samples exposing (..)",
    "",
    "import Code128 exposing (Width(..))",
    "",
    "samples = [",
    samples,
    "  ]",
  ]

  console.log(output.join("\n"))
}

function encode(a) {
  try {
    const bits = new CODE128(a, {}).encode().data
    return "Just [" + toWidths(bits) + "]"
  } catch (e) {
    return "Nothing"
  }
}

function toWidths(a) {
  return a
    .replaceAll("1111", "Width4 ")
    .replaceAll("0000", "Width4 ")

    .replaceAll("111", "Width3 ")
    .replaceAll("000", "Width3 ")

    .replaceAll("11", "Width2 ")
    .replaceAll("00", "Width2 ")

    .replaceAll("1", "Width1 ")
    .replaceAll("0", "Width1 ")

    .trim()
    .split(" ")
    .join(", ")
}
