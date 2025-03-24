///|
pub(all) struct Datetime {
  date : Date?
  time : Time?
  offset : Offset?
} derive(Show)

///|
pub(all) struct Date {
  year : Int
  month : Int
  day : Int
} derive(Show)

///|
pub(all) struct Time {
  hour : Int
  minute : Int
  second : Int
  nanosecond : Int64
} derive(Show)

///|
pub(all) enum Offset {
  Utc
  Add(hour~ : Int, minute~ : Int)
  Sub(hour~ : Int, minute~ : Int)
} derive(Show)

///|
pub fn Date::is_valid(self : Date) -> Bool {
  if self.year < 0 || self.year > 9999 {
    return false
  }
  if self.month < 1 || self.month > 12 {
    return false
  }
  let is_leap_year = self.year % 4 == 0 &&
    (self.year % 100 != 0 || self.year % 400 == 0)
  let max_days_in_month = match self.month {
    2 if is_leap_year => 29
    2 => 28
    4 | 6 | 9 | 11 => 30
    _ => 31
  }
  if self.day < 1 || self.day > max_days_in_month {
    return false
  }
  true
}

///|
pub fn Time::is_valid(self : Time) -> Bool {
  if self.hour < 0 || self.hour > 24 {
    return false
  }
  if self.minute < 0 || self.minute > 59 {
    return false
  }
  if self.second < 0 || self.second > 60 {
    return false
  }
  if self.nanosecond < 0 || self.nanosecond > 999_999_999 {
    return false
  }
  true
}

///|
pub fn Offset::is_valid(self : Offset) -> Bool {
  if self is (Add(hour~, minute~) | Sub(hour~, minute~)) {
    if hour < 0 || hour > 24 {
      return false
    }
    if minute < 0 || minute > 59 {
      return false
    }
  }
  true
}

///|
pub fn Datetime::is_valid(self : Datetime) -> Bool {
  if (self.date is None || self.time is None) && not(self.offset is None) {
    return false
  }
  if self.date is None && self.time is None {
    return false
  }
  if self.date is Some(date) && not(date.is_valid()) {
    return false
  }
  if self.time is Some(time) && not(time.is_valid()) {
    return false
  }
  if self.offset is Some(offset) && not(offset.is_valid()) {
    return false
  }
  true
}
