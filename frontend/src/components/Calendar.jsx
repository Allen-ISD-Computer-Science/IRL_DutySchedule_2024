import React, { useState, useRef } from "react";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";

function Calendar(props) {
  const [didRequest, setDidRequest] = useState("");
  const calendarRef = useRef(0);

  const setTime = (date, str) => {
    const args = str.split(":").map((a) => parseInt(a));
    date.setHours(args[0], args[1], args[2]);
  };

  /**
   * @param {[]} eventsData
   */
  const updateEvents = (eventsData) => {
    console.log(eventsData);
    const api = calendarRef.current.getApi();
    api.removeAllEvents();
    
    eventsData.forEach((e) => {
      const event = {};
      event.title = e.dutyName;

      var dayNums = e.day
        .split("T")[0]
        .split("-")
        .map((a) => parseInt(a));
      dayNums[1] = dayNums[1] - 1;

      const day = new Date(...dayNums);
      setTime(day, e.startTime);
      event.start = new Date(day.getTime());

      setTime(day, e.endTime);
      event.end = day;

      console.log(event);
      api.addEvent(event);
    });
    props.eventsRef.current = eventsData;
  };

  /**
   * @param {DayCellContentArg} info
   */
  const updateDayColor = (info) => {
    return (
      <span
        style={{ color: "gray" }}
        id={`dayNum-${info.date.toISOString().split("T")[0]}`}
      >
        {info.dayNumberText}
      </span>
    );
  };

  const updateDayColors = (info, dateInfo) => {
    // loop through info.start to info.end
    const start = new Date(info.start);
    while (start < info.end) {
      const date = new Date(start);
      const dayNum = document.getElementById(
        `dayNum-${date.toISOString().split("T")[0]}`
      );
      if (dayNum) {
        const dayInfo = dateInfo.find(
          (a) => a.day.split("T")[0] === date.toISOString().split("T")[0]
        );
        dayNum.style.color = dayInfo
          ? dayInfo.supplementaryJSON.abDay === "A"
            ? "#c03a2a"
            : "#161b5f"
          : "gray";
      }
      start.setDate(start.getDate() + 1);
    }
  };

  const getData = (info) => {
    if (didRequest === info.start.toISOString() + "+" + info.end.toISOString())
      return;

    setDidRequest(info.start.toISOString() + "+" + info.end.toISOString());
    try {
      // make http request to get data
      fetch(process.env.PUBLIC_URL + "/calendar/data", {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        method: "POST",
        body: JSON.stringify({
          from: info.start.toISOString().split("T")[0] + "T00:00:00Z",
          through: info.end.toISOString().split(".")[0] + "Z",
        }),
      })
        .then((response) => response.json())
        .then((json) => {
          updateDayColors(info, json);
        });
    } catch (err) {
      console.error(err);
    }
    try {
      // make http request to get data
      fetch(process.env.PUBLIC_URL + "/duties/user/date", {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        method: "POST",
        body: JSON.stringify({
          from: info.start.toISOString().split("T")[0] + "T00:00:00Z",
          through: info.end.toISOString().split(".")[0] + "Z",
        }),
      })
        .then((response) => response.json())
        .then((json) => {
          updateEvents(json);
        });
    } catch (err) {
      console.error(err);
    }
  };

  if (props.timeGrid === true) {
    return (
      <FullCalendar
        className="d-block"
        themeSystem="bootstrap5"
        plugins={[timeGridPlugin]}
        initialView="timeGridWeek"
        hiddenDays={[0, 6]}
        nowIndicator={true}
        slotMinTime={"06:00:00"}
        slotMaxTime={"19:00:00"}
        allDayClassNames={
          "text-center w-100 justify-content-center align-items-center"
        }
        allDayContent={"All Day"}
        slotLabelContent={(args) => {
          return args.date.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
            hour12: true,
          });
        }}
        contentHeight={"auto"}
        eventClick={props.eventClick}
        datesSet={getData}
        ref={calendarRef}
      />
    );
  }

  return (
    <FullCalendar
      ref={calendarRef}
      themeSystem="bootstrap5"
      plugins={[dayGridPlugin]}
      initialView="dayGridMonth"
      datesSet={getData}
      dayCellContent={updateDayColor}
      hiddenDays={[0, 6]}
      eventClick={props.eventClick}
    />
  );
}

export default Calendar;
