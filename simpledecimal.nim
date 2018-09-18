## Decimal data representation
# Copyright (C) Jedrzej Nowak
# MIT LICENSE - Details in license.txt

from strutils import intToStr, parseInt, split, find

type
  Decimal* = object ## Represents a decimal value.
    dv: int32
    val: int64

proc toDecimal*(intPart: int, fractionPart=0; decimalPlaces=2): Decimal =
  ## General constructor.
  if decimalPlaces == 2:
    result.dv = 100
  elif decimalPlaces == 4:
    result.dv = 10_000
  else:
    var dv = 1
    for i in 1..decimalPlaces: dv *= 10
    result.dv = dv.int32
  result.val = intPart * result.dv + fractionPart

proc toDecimal*(decimal: string): Decimal =
  ## Create from string
  let dotPos = decimal.find(".")
  if dotPos == -1:
    result = toDecimal(decimal.parseInt)
  else:
    let sp = decimal.split(".", 1)
    result = toDecimal(sp[0].parseInt, sp[1].parseInt, decimal.len - dotPos - 1)

proc m0*(x: int): Decimal =
  ## Constructor for Decimals with 1 decimal place.
  Decimal(dv: 10, val: x*10)

proc m00*(x: int): Decimal =
  ## Constructor for Decimals with 2 decimal places.
  Decimal(dv: 100, val: x*100)

proc m000*(x: int): Decimal =
  ## Constructor for Decimals with 3 decimal places.
  Decimal(dv: 1000, val: x*1000)

proc m0000*(x: int): Decimal =
  ## Constructor for Decimals with 4 decimal places.
  Decimal(dv: 10_000, val: x*10_000)

proc decimalPlaces*(x: Decimal): int =
  result = 0
  var dv = x.dv
  while dv >= 10:
    dv = dv div 10
    inc result

proc `$`*(a: Decimal; sep='.'): string =
  result = $(a.val div a.dv) & sep & intToStr(int(a.val mod a.dv), decimalPlaces(a))

proc convert(a, b: Decimal): int64 =
  ## convert a's to b's representation
  # a = 10, b = 1000  --> diff = 100
  assert b.dv > a.dv
  let diff = b.dv div a.dv
  assert b.dv mod a.dv == 0
  result = a.val * diff

template plusOp(op: untyped) =
  proc op*(a, b: Decimal): Decimal =
    if a.dv == b.dv:
      result = Decimal(dv: a.dv, val: op(a.val, b.val))
    elif a.dv > b.dv:
      # convert b to a's representation
      result = Decimal(dv: a.dv, val: op(a.val, convert(b, a)))
    else:
      # convert a to b's representation
      result = Decimal(dv: b.dv, val: op(convert(a, b), b.val))

template mulOp(op: untyped) =
  proc op*(a: Decimal; b: int64): Decimal =
    Decimal(dv: a.dv, val: op(a.val, b))

template unOp(op: untyped) =
  proc op*(a: Decimal): Decimal = Decimal(dv: a.dv, val: op(a.val))

plusOp(`+`)
plusOp(`-`)
mulOp(`*`)
mulOp(`div`)
mulOp(`mod`)
unOp(`-`)

proc sum*(x: openArray[Decimal]): Decimal =
  result = x[0]
  for i in 1..<x.len:
    result = result + x[i]

proc avg*(x: openArray[Decimal]): Decimal =
  sum(x) div x.len


when isMainModule:
  import unittest

  suite "basic":
    test "construction":
      let a = 1.m0
      check($a == "1.0")

    test "addition":
      let a = 33.m0
      let b = 1.m00
      check(a + b == 34.m00)

    test "substract":
      let a = 33.m0
      let b = 1.m00
      check(a - b == 32.m00)

    test "mul":
      let b = 3.m0 * 5
      let c = 15.m0
      check(b == c)

    test "from string":
      let a = "12.34".toDecimal
      let b = "3.66".toDecimal
      check(a + b == 16.m00)
