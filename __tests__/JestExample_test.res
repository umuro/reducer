// See https://github.com/glennsl/rescript-jest/blob/master/__tests__/expect_test.res

open Jest

describe("Expect", () => {
  open Expect

  test("toBe", () =>
    expect(1 + 2) -> toBe(3))
})

describe("Expect.Operators", () => {
    open Expect
    open! Expect.Operators

    test("==", () =>
      expect(1 + 2) === 3)
  }
)
