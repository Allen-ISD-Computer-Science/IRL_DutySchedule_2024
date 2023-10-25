import React from 'react';
import { Button, Container } from 'react-bootstrap';

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCalendar, faClock, faMapPin, faClipboard, faBullhorn } from '@fortawesome/free-solid-svg-icons'

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
                    <br></br>
                     <Container className='shadow p-3 mb-5 bg-white rounded mt-4'>
                      <h4><FontAwesomeIcon icon={faBullhorn} /> Announcements:</h4>
                      <br></br>
                          <h3> {props.announcement || " There is no school on 01/01/2025 "}</h3>
                          <br></br>




                  </Container>

                    <Container className='shadow p-3 mb-5 bg-white rounded mt-4'>
                      <h4> Your Next duty:</h4>
                      <br></br>
                          <h3><FontAwesomeIcon icon={faClipboard} /> {props.nextDutyName || " Bus Duty"}</h3>
                          <br></br>
                          <p><FontAwesomeIcon icon={faCalendar} /> {props.nextDutyDate || " 01/02/2025"}</p>
                      <p><FontAwesomeIcon icon={faClock} /> {props.nextDutyTime || " 4:00-5:00 PM"}</p>
                      <p><FontAwesomeIcon icon={faMapPin} /> {props.nextDutyLocation || " PAC"}</p>



                  </Container>


                    <Container className='shadow p-3 mb-5 bg-white rounded mt-4'>
                    <FullCalendar
                        className="d-block"
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
                        }
                        </Container>
                </Container>
            </div>
        </section>

    </main>
  );
}

export default DashboardPage;
