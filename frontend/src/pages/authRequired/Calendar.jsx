import React from 'react';
import { Container } from 'react-bootstrap';

import Navbar from '../../components/Navbar'
import Calendar from '../../components/Calendar';

function CalendarPage() {
  return (
    <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
        <Navbar />
        <section className="d-flex align-items-center">
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <Container>
                    <Calendar />
                </Container>
            </div>
        </section>

    </main>
  );
}

export default CalendarPage;