import React from 'react';
import { Container } from 'react-bootstrap';

import Navbar from '../../components/Navbar'

import FullCalendar from '@fullcalendar/react'
import timeGridPlugin from '@fullcalendar/timegrid'

import "./calendar.css"

function DashboardPage() {
  return (
    <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
        <Navbar />
        <section className="d-flex align-items-center">
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <Container>
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
                </Container>
            </div>
        </section>

    </main>
  );
}

export default DashboardPage;