import React, { useState, useEffect, useRef } from "react";

import Container from "react-bootstrap/Container";

import FullCalendar from "@fullcalendar/react";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin, { Draggable } from '@fullcalendar/interaction';

import "./shiftEditorMenu.css";

function ShiftEditorMenu(props) {

    const containerRef = useRef(null);
    const [shifts, setShifts] = useState([
        {
            name: "Monitor",
            location: "Cafeteria",
        },
        {
            name: "Tutor",
            location: "Library",
        }
    ]);

    useEffect(() => {
        new Draggable(containerRef.current, {
            itemSelector: '.shift'
        });
        console.log("Called")
    });
    
    return (
        <Container className="d-flex justify-content-between align-items-stretch p-2">
            <Container className="w-25">
                <h1>Shift Editor</h1>

                <h2>Shifts</h2>
                <Container className="shifts-container" ref={containerRef}>
                    {
                        shifts.map((shift, i) => {
                            return (
                                <Container key={i} className="shift" id={`shift-${i}`} data-event={`{ "title": "${shift.name} - ${shift.location}", "duration": "02:00" }`}>
                                    <h3>{shift.name}</h3>
                                    <p>Location: {shift.location}</p>
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
                />
            </Container>
        </Container>
    );

}

export default ShiftEditorMenu;