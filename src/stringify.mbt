///|
fn zero_pad[T : Show](val : T, len : Int) -> String!Error {
  let str = val.to_string()
  let pad_len = len - str.length()
  guard pad_len >= 0 else {
    fail!("the print len of val(\{val}) exceeds \{len}")
  }
  "0".repeat(pad_len) + str
}

///|
fn Date::stringify(self : Date) -> String!Error {
  guard self.is_valid() else { fail!("Invalid date: \{self}") }
  "\{zero_pad!(self.year, 4)}-\{zero_pad!(self.month, 2)}-\{zero_pad!(self.day, 2)}"
}

///|
fn Time::stringify(self : Time) -> String!Error {
  guard self.is_valid() else { fail!("Invalid time: \{self}") }
  let nanosecond_str = if self.nanosecond != 0 {
    "." + zero_pad!(self.nanosecond, 9).trim_end("0")
  } else {
    ""
  }
  "\{zero_pad!(self.hour, 2)}:\{zero_pad!(self.minute, 2)}:\{zero_pad!(self.second, 2)}\{nanosecond_str}"
}

///|
fn Offset::stringify(self : Offset) -> String!Error {
  guard self.is_valid() else { fail!("Invalid offset: \{self}") }
  match self {
    Utc => "Z"
    Add(hour~, minute~) => "+\{zero_pad!(hour, 2)}:\{zero_pad!(minute, 2)}"
    Sub(hour~, minute~) => "-\{zero_pad!(hour, 2)}:\{zero_pad!(minute, 2)}"
  }
}

///|
pub fn stringify(datetime : Datetime, delimiter~ : Char = 'T') -> String!Error {
  guard datetime.is_valid() else { fail!("Invalid datetime: \{datetime}") }
  guard delimiter is ('T' | 't' | ' ') else {
    fail!("Invalid delimiter: \{delimiter}")
  }
  let buf = StringBuilder::new()
  if datetime.date is Some(date) {
    buf.write_string(date.stringify!())
  }
  if datetime.time is Some(time) {
    if not(datetime.date.is_empty()) {
      buf.write_char(delimiter)
    }
    buf.write_string(time.stringify!())
  }
  if datetime.offset is Some(offset) {
    buf.write_string(offset.stringify!())
  }
  buf.to_string()
}
