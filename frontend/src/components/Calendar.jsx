import React, { useState, useRef } from 'react'
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid' // a plugin!

import { DayCellContentArg } from '@fullcalendar/core'

function Calendar() {

    const [didRequest, setDidRequest] = useState("");
    const [dateInfo, setDateInfo] = useState([]);
    const eventsRef = useRef(0);
    const calendarRef = useRef(0);

    const setTime = (date, str) => {
	const args = str.split(":").map(a => parseInt(a));
	date.setHours(args[0], args[1], args[2]);
    }

    /**
     * @param {[]} eventsData
     */
    const updateEvents = (eventsData) => {
        console.log(eventsData);
        const api = calendarRef.current.getApi();
        eventsData.forEach(e => {
	    const event = {};
	    event.title = e.dutyName;
	    const day = new Date(e.day);
	    setTime(day, e.startTime);
	    event.start = new Date(day.getTime());
	    setTime(day, e.endTime);
	    event.end = day;
	    console.log(event)
            api.addEvent(event);
        });
	eventsRef.current = eventsData;
    }

    /**
     * @param {DayCellContentArg} info
     */
    const updateDayColor = (info) => {
        return (
            <span style={{ color: "gray" }} id={`dayNum-${info.date.toISOString().split('T')[0]}`}>
                {info.dayNumberText}
            </span>
        );
    }

    const updateDayColors = (info, dateInfo) => {
        // loop through info.start to info.end
        const start = new Date(info.start);
        while (start < info.end) {
            const date = new Date(start);
            const dayNum = document.getElementById(`dayNum-${date.toISOString().split('T')[0]}`);
            if (dayNum) {
                const dayInfo = dateInfo.find(a => a.day.split("T")[0] === date.toISOString().split("T")[0]);
                dayNum.style.color = dayInfo ? (dayInfo.supplementaryJSON.abDay === "A" ? "#c03a2a" : "#161b5f") : "gray";
            }
            start.setDate(start.getDate() + 1);
        }
    }

    const getData = (info) => {
        if (didRequest === info.start.toISOString() + "+" + info.end.toISOString()) return;

        setDidRequest(info.start.toISOString() + "+" + info.end.toISOString());
        try {
            // make http request to get data
            fetch(process.env.PUBLIC_URL + "/calendar/data",
                {
                    headers: {
                        'Accept': 'application/json',
                        "Content-Type": "application/json",
                    },
                    method: "POST",
                    body: JSON.stringify({ from: info.start.toISOString().split("T")[0] + "T00:00:00Z", through: info.end.toISOString().split(".")[0] + "Z" })
                })
                .then((response) => response.json())
                .then((json) => {
                    setDateInfo(json);
                    updateDayColors(info, json);
                });
        } catch (err) {
            console.error(err);
        }
        try {
            // make http request to get data
            fetch(process.env.PUBLIC_URL + "/duties/user/date",
                {
                    headers: {
                        'Accept': 'application/json',
                        "Content-Type": "application/json",
                    },
                    method: "POST",
                    body: JSON.stringify({ from: info.start.toISOString().split("T")[0] + "T00:00:00Z", through: info.end.toISOString().split(".")[0] + "Z" })
                })
                .then((response) => response.json())
                .then((json) => {
                    updateEvents(json);
                });
        } catch (err) {
            console.error(err);
        }
    }

    return (
        <FullCalendar
            ref={calendarRef}
            themeSystem='bootstrap5'
            plugins={[dayGridPlugin]}
            initialView="dayGridMonth"
            datesSet={getData}
            dayCellContent={updateDayColor}
            hiddenDays={[0, 6]}
        />
    )
}

export default Calendar;
