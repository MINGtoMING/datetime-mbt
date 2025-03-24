///|
test "stringify" {
  let datetime = Datetime::{
    date: Some({ year: 2024, month: 10, day: 11 }),
    time: Some({ hour: 12, minute: 11, second: 57, nanosecond: 240000000 }),
    offset: Some(Add(hour=12, minute=11)),
  }
  assert_eq!(stringify!(datetime), "2024-10-11T12:11:57.24+12:11")
  let datetime = Datetime::{
    date: Some({ year: 2024, month: 10, day: 11 }),
    time: Some({ hour: 12, minute: 11, second: 57, nanosecond: 240000000 }),
    offset: None,
  }
  assert_eq!(stringify!(datetime), "2024-10-11T12:11:57.24")
  let datetime = Datetime::{
    date: Some({ year: 2024, month: 10, day: 11 }),
    time: None,
    offset: None,
  }
  assert_eq!(stringify!(datetime), "2024-10-11")
  let datetime = Datetime::{
    date: None,
    time: Some({ hour: 12, minute: 11, second: 57, nanosecond: 240000000 }),
    offset: None,
  }
  assert_eq!(stringify!(datetime), "12:11:57.24")
}
