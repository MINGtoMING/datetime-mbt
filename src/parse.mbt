///|
priv struct Context {
  str : String
  max_idx : Int
  mut idx : Int
}

///|
fn Context::make(str : String) -> Context {
  { str, max_idx: str.length(), idx: 0 }
}

///|
let datetime_legal_chars : Set[Char] = Set::of([
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-', ' ', '.', 'Z', 'z',
  ':', 'T', 't',
])

///|
fn Context::next(self : Context) -> Char?!Error {
  if self.idx < self.max_idx {
    let char = self.str[self.idx]
    if datetime_legal_chars.contains(char) {
      self.idx += 1
      Some(char)
    } else {
      fail!("Illegal char: \{char}")
    }
  } else {
    None
  }
}

///|
fn Context::digit(self : Context) -> Int!Error {
  match self.next!() {
    Some(char) if char is ('0'..='9') => char.to_int() - 48 // the ascii of '0' is 48
    _ => fail!("Expect char from '0' to '9'")
  }
}

///|
fn parse_date(ctx : Context) -> Date!Error {
  let y1 = ctx.digit!()
  let y2 = ctx.digit!()
  let y3 = ctx.digit!()
  let y4 = ctx.digit!()
  let year = y1 * 1000 + y2 * 100 + y3 * 10 + y4
  guard ctx.next!() is Some('-') else { fail!("Expect char '-'") }
  let m1 = ctx.digit!()
  let m2 = ctx.digit!()
  let month = m1 * 10 + m2
  guard ctx.next!() is Some('-') else { fail!("Expect char '-'") }
  let d1 = ctx.digit!()
  let d2 = ctx.digit!()
  let day = d1 * 10 + d2
  { year, month, day }
}

///|
fn parse_time(ctx : Context) -> Time!Error {
  let h1 = ctx.digit!()
  let h2 = ctx.digit!()
  let hour = h1 * 10 + h2
  guard ctx.next!() is Some(':') else { fail!("Expect char ':'") }
  let m1 = ctx.digit!()
  let m2 = ctx.digit!()
  let minute = m1 * 10 + m2
  guard ctx.next!() is Some(':') else { fail!("Expect char ':'") }
  let s1 = ctx.digit!()
  let s2 = ctx.digit!()
  let second = s1 * 10 + s2
  let nanosecond = parse_nanosecond!(ctx)
  { hour, minute, second, nanosecond }
}

///|
fn parse_nanosecond(ctx : Context) -> Int64!Error {
  let mut nanosecond : Int64 = 0
  if ctx.next!() is Some('.') {
    let mut count = 0
    while ctx.next!() is Some(char) {
      match char {
        '0'..='9' if count < 9 => {
          let p = 10.0.pow((8 - count).to_double())
          nanosecond += p.to_int64() * (char.to_int() - 48).to_int64()
          count += 1
        }
        _ => {
          ctx.idx -= 1
          break
        }
      }
    }
    guard count > 0 else { fail!("Expect digit after char '.'") }

  } else {
    ctx.idx -= 1
  }
  nanosecond
}

///|
fn parse_offset(ctx : Context) -> Offset!Error {
  if ctx.next!() is Some(char) {
    if char == 'Z' || char == 'z' {
      return Utc
    }
    let is_add = if char == '+' {
      true
    } else if char == '-' {
      false
    } else {
      fail!("Invalid char '\{char}'")
    }
    let h1 = ctx.digit!()
    let h2 = ctx.digit!()
    let hour = h1 * 10 + h2
    guard ctx.next!() is Some(':') else { fail!("Expect char ':'") }
    let m1 = ctx.digit!()
    let m2 = ctx.digit!()
    let minute = m1 * 10 + m2
    if is_add {
      Add(hour~, minute~)
    } else {
      Sub(hour~, minute~)
    }
  } else {
    fail!("Unexpected None")
  }
}

///|
/// - Offset Date-Time 0000-00-00T00:00:00.00Z
/// - Local Date-Time 0000-00-00T00:00:00.00
/// - Local Date 0000-00-00
/// - Local Time 00:00:00.00
pub fn parse(str : String) -> Datetime!Error {
  let ctx = Context::make(str)
  // Min length case: 00:00:00
  if ctx.max_idx < 8 {
    fail!("Invalid datetime length")
  }
  let has_date = str[2] != ':'
  let date = if has_date {
    let date = parse_date!(ctx)
    guard date.is_valid() else { fail!("Invalid date: \{date}") }
    Some(date)
  } else {
    None
  }
  let has_time = (date is Some(_) && ctx.next!() is Some('T' | 't' | ' ')) ||
    date is None
  let time = if has_time {
    let time = parse_time!(ctx)
    guard time.is_valid() else { fail!("Invalid time \{time}") }
    Some(time)
  } else {
    None
  }
  let allow_offset = date is Some(_) && time is Some(_)
  let has_offset = ctx.idx < ctx.max_idx
  let offset = if allow_offset && has_offset {
    let offset = parse_offset!(ctx)
    guard offset.is_valid() else { fail!("Invalid offset \{offset}") }
    Some(offset)
  } else {
    None
  }
  guard ctx.next!() is None else { fail!("Expect None") }
  { date, time, offset }
}
