import React, { useState } from 'react'
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid' // a plugin!

import { DayCellContentArg } from '@fullcalendar/core'

function Calendar() {

    const [dateInfo, setDateInfo] = useState({});

    /**
     * @param {DayCellContentArg} info
     */
    const colorAorB = (date) => {
        if ([0, 6].includes(date.getDay())) return "black";
        if (date.getDate() % 2 === 0) return "#c03a2a";
        return "#161b5f";
    }

    /**
     * @param {DayCellContentArg} info
     */
    const updateDayColor = (info) => {
        // will eventually use dateInfo object to determine color
        // for now, just use colorAorB
        return (
            <span style={{ color: "gray"}} id={`dayNum-${info.date.toISOString().split('T')[0]}`}>
                {info.dayNumberText}
            </span>
        );
    }

    const updateDayColors = (info) => {
        // loop through info.start to info.end
        const start = new Date(info.start);
        while (start < info.end) {
            const date = new Date(start);
            const dayNum = document.getElementById(`dayNum-${date.toISOString().split('T')[0]}`);
            if (dayNum) {
                console.log(dateInfo.find(a => a.day === date.toISOString()));
                dayNum.style.color = dateInfo.find(a => a.day === date.toISOString()).supplementaryJSON.abDay ? "#c03a2a" : "#161b5f";
            }
            start.setDate(start.getDate() + 1);
        }
    }

    const getData = (info) => {
        // make http request to get data
        fetch(process.env.PUBLIC_URL + "/calendar/data",
        {
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            },
            method: "POST",
            body: JSON.stringify({from: info.start, through: info.end})
        })
        .then((response) => response.json())
        .then((json) => {
            setDateInfo(json);
            updateDayColors();
        });
    }

    return (
        <FullCalendar
            themeSystem='bootstrap5'
            plugins={[ dayGridPlugin ]}
            initialView="dayGridMonth"
            datesSet={getData}
            dayCellContent={updateDayColor}
            hiddenDays={[0, 6]}
        />
    )
}

export default Calendar;
