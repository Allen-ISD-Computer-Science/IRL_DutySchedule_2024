import React, { useState, useEffect, useRef } from "react";

import Container from "react-bootstrap/Container";

import FullCalendar from "@fullcalendar/react";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin, { Draggable } from '@fullcalendar/interaction';

import "./shiftEditorMenu.css";

function ShiftEditorMenu(props) {

    const containerRef = useRef(null);
    const [didRequestURL, setDidRequestURL] = useState("");


    const [shifts, setShifts] = useState([]);

    useEffect(() => {
        new Draggable(containerRef.current, {
            itemSelector: '.shift'
        });
        console.log("Called")
    });

    const getData = (info) => {
        const requestURL = `${process.env.PUBLIC_URL}/adminPanel/duties/available/${props.userId}-${info.start.toISOString()}-${info.end.toISOString()}`;
        if (didRequestURL === requestURL) return;
        setDidRequestURL(requestURL);

        fetch(`${process.env.PUBLIC_URL}/adminPanel/duties/available/${props.userId}`, {
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
                setShifts(json);
            });
    };
    
    return (
        <Container className="d-flex justify-content-between align-items-stretch p-2">
            <Container className="w-25" style={{ overflow: "hidden", maxHeight: "89.5vh" }}>
                <h1>Shift Editor</h1>

                <h2>Shifts</h2>
                <Container className="shifts-container" ref={containerRef}>
                    {
                        shifts.map((shift, i) => {
                            return (
                                <Container key={i} className="shift" id={`shift-${i}`} data-event={`{ "title": "${shift.dutyName} - ${shift.locationName}", "duration": "02:00" }`}>
                                    <h3>{shift.dutyName}</h3>
                                    <p>Location: {shift.locationName}</p>
                                </Container>
                            );
                        })
                    }
                </Container>
            </Container>
            <Container className="w-75">
                <FullCalendar
                    className="d-block"
                    themeSystem="bootstrap5"
                    plugins={[timeGridPlugin, interactionPlugin]}
                    initialView="timeGridWeek"
                    hiddenDays={[0, 6]}
                    nowIndicator={false}
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
                    droppable={true}
                    datesSet={getData}
                />
            </Container>
        </Container>
    );

}

export default ShiftEditorMenu;