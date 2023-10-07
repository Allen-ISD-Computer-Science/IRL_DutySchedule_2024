import React from 'react';
import { Container } from 'react-bootstrap';

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCalendar, faClock } from '@fortawesome/free-solid-svg-icons'

import FullCalendar from '@fullcalendar/react'
import timeGridPlugin from '@fullcalendar/timegrid'

import Navbar from '../../components/Navbar'

import "./calendar.css"

function DashboardPage(props) {
  return (
    <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
        <Navbar />
        <section className="d-flex align-items-center">
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <Container>
                  <h2>Welcome {props.name || "User"}!</h2>
                  <Container className='shadow p-3 mb-5 bg-white rounded mt-4'>
                    <h4><FontAwesomeIcon icon={faCalendar} /> Next duty:</h4>
                    <h3>{" " + props.nextDutyDate || "Not Recorded"}</h3>
                    <p><FontAwesomeIcon icon={faClock} /> {props.nextDutyTime || "None"}</p>
                  </Container>

                  {
                    false ? 
                    <FullCalendar
                      themeSystem='bootstrap5'
                      plugins={[ timeGridPlugin ]}
                      initialView="timeGridWeek"
                      hiddenDays={[0, 6]}
                      nowIndicator={true}
                      slotMinTime={"06:00:00"}
                      slotMaxTime={"19:00:00"}
                      allDayClassNames={"text-center w-100 justify-content-center align-items-center"}
                      allDayContent={"All Day"}
                      slotLabelContent={(args) => {
                        return args.date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', hour12: true});
                      }}
                      contentHeight={"auto"}
                    />
                    : ""
                  }
                </Container>
            </div>
        </section>

    </main>
  );
}

export default DashboardPage;