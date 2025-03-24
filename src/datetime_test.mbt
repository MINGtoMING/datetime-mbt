///|
test "Data::is_valid" {
  assert_eq!(Date::{ year: 2024, month: 10, day: 11 }.is_valid(), true)
  assert_eq!(Date::{ year: 2024, month: 2, day: 29 }.is_valid(), true)
  assert_eq!(Date::{ year: 2000, month: 6, day: 30 }.is_valid(), true)
  assert_eq!(Date::{ year: 0, month: 1, day: 1 }.is_valid(), true)
  assert_eq!(Date::{ year: 9999, month: 12, day: 31 }.is_valid(), true)
  assert_eq!(Date::{ year: -1, month: 1, day: 1 }.is_valid(), false)
  assert_eq!(Date::{ year: 10000, month: 12, day: 31 }.is_valid(), false)
  assert_eq!(Date::{ year: 2024, month: 0, day: 11 }.is_valid(), false)
  assert_eq!(Date::{ year: 2024, month: 10, day: 0 }.is_valid(), false)
  assert_eq!(Date::{ year: 2024, month: 10, day: 32 }.is_valid(), false)
  assert_eq!(Date::{ year: 2023, month: 2, day: 28 }.is_valid(), true)
  assert_eq!(Date::{ year: 2028, month: 2, day: 29 }.is_valid(), true)
  assert_eq!(Date::{ year: 3100, month: 2, day: 29 }.is_valid(), false)
}

///|
test "Time::is_valid" {
  assert_eq!(
    Time::{ hour: 12, minute: 11, second: 57, nanosecond: 240_000_000 }.is_valid(),
    true,
  )
  assert_eq!(
    Time::{ hour: 25, minute: 11, second: 57, nanosecond: 240_000_000 }.is_valid(),
    false,
  )
  assert_eq!(
    Time::{ hour: 12, minute: 60, second: 57, nanosecond: 240_000_000 }.is_valid(),
    false,
  )
  assert_eq!(
    Time::{ hour: 12, minute: 11, second: 61, nanosecond: 240_000_000 }.is_valid(),
    false,
  )
  assert_eq!(
    Time::{ hour: 12, minute: 11, second: 57, nanosecond: 1_000_000_000 }.is_valid(),
    false,
  )
}

///|
test "Offset::is_valid" {
  assert_eq!(Offset::Utc.is_valid(), true)
  assert_eq!(Offset::Add(hour=12, minute=11).is_valid(), true)
  assert_eq!(Offset::Sub(hour=12, minute=11).is_valid(), true)
  assert_eq!(Offset::Add(hour=26, minute=11).is_valid(), false)
  assert_eq!(Offset::Sub(hour=26, minute=11).is_valid(), false)
  assert_eq!(Offset::Add(hour=12, minute=60).is_valid(), false)
  assert_eq!(Offset::Sub(hour=12, minute=60).is_valid(), false)
}

///|
test "Datetime::is_valid" {
  let valid_date = Date::{ year: 2024, month: 10, day: 11 }
  let valid_time = Time::{
    hour: 12,
    minute: 11,
    second: 57,
    nanosecond: 240_000_000,
  }
  let valid_offset = Offset::Add(hour=12, minute=11)
  let invalid_date = Date::{ year: 3100, month: 2, day: 29 }
  let invalid_time = Time::{
    hour: 12,
    minute: 60,
    second: 57,
    nanosecond: 240_000_000,
  }
  let invalid_offset = Offset::Add(hour=25, minute=11)
  // Offset Date-Time
  assert_eq!(
    Datetime::{
      date: Some(valid_date),
      time: Some(valid_time),
      offset: Some(valid_offset),
    }.is_valid(),
    true,
  )
  assert_eq!(
    Datetime::{
      date: Some(invalid_date),
      time: Some(valid_time),
      offset: Some(valid_offset),
    }.is_valid(),
    false,
  )
  assert_eq!(
    Datetime::{
      date: Some(valid_date),
      time: Some(invalid_time),
      offset: Some(valid_offset),
    }.is_valid(),
    false,
  )
  assert_eq!(
    Datetime::{
      date: Some(valid_date),
      time: Some(valid_time),
      offset: Some(invalid_offset),
    }.is_valid(),
    false,
  )
  // Local Date-Time
  assert_eq!(
    Datetime::{ date: Some(valid_date), time: Some(valid_time), offset: None }.is_valid(),
    true,
  )
  assert_eq!(
    Datetime::{ date: Some(invalid_date), time: Some(valid_time), offset: None }.is_valid(),
    false,
  )
  assert_eq!(
    Datetime::{ date: Some(valid_date), time: Some(invalid_time), offset: None }.is_valid(),
    false,
  )
  // Local Date
  assert_eq!(
    Datetime::{ date: Some(valid_date), time: None, offset: None }.is_valid(),
    true,
  )
  assert_eq!(
    Datetime::{ date: Some(invalid_date), time: None, offset: None }.is_valid(),
    false,
  )
  // Local Time
  assert_eq!(
    Datetime::{ date: None, time: Some(valid_time), offset: None }.is_valid(),
    true,
  )
  assert_eq!(
    Datetime::{ date: None, time: Some(invalid_time), offset: None }.is_valid(),
    false,
  )
  // Invalid case
  assert_eq!(
    Datetime::{ date: Some(valid_date), time: None, offset: Some(valid_offset) }.is_valid(),
    false,
  )
  assert_eq!(
    Datetime::{ date: None, time: None, offset: None }.is_valid(),
    false,
  )
}
