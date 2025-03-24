///|
test "parse" {
  inspect!(
    parse!("2024-10-11T12:11:57.24+12:11"),
    content="{date: Some({year: 2024, month: 10, day: 11}), time: Some({hour: 12, minute: 11, second: 57, nanosecond: 240000000}), offset: Some(Add(hour=12, minute=11))}",
  )
  inspect!(
    parse!("2024-10-11T12:11:57.24"),
    content="{date: Some({year: 2024, month: 10, day: 11}), time: Some({hour: 12, minute: 11, second: 57, nanosecond: 240000000}), offset: None}",
  )
  inspect!(
    parse!("2024-10-11"),
    content="{date: Some({year: 2024, month: 10, day: 11}), time: None, offset: None}",
  )
  inspect!(
    parse!("12:11:57.24"),
    content="{date: None, time: Some({hour: 12, minute: 11, second: 57, nanosecond: 240000000}), offset: None}",
  )
}
