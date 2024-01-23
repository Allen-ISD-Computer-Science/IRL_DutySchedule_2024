import React from "react";
import { Button, Container, Modal } from "react-bootstrap";

import AdminNavbar from "../../components/AdminNavbar";
import Calendar from "../../components/Calendar";
import ShiftAssignerMenu from "../../components/ShiftAssignerMenu";

function AdminCalendar() {
    const [dutyId, setDutyId] = React.useState(-1);
    const [showAssignerMenu, setShowAssignerMenu] = React.useState(false);

    const eventsRef = React.useRef({});

    const eventClick = (info) => {
        if (["A Day", "B Day"].includes(info.event.title)) return;

        const event = eventsRef.current.find((a) => {
            var dayNums = a.day
                .split("T")[0]
                .split("-")
                .map((b) => parseInt(b));
            dayNums[1] = dayNums[1] - 1;

            const day = new Date(...dayNums);
            day.setHours(...a.startTime.split(":").map((a) => parseInt(a)));
            console.log(day.toString(), day.getTime());
            return (
                a.dutyName === info.event.title &&
                day.getTime() === info.event.start.getTime()
            );
        });

        if (!event) {
            throw new Error(
                `Couldn't find event: ${info.event.title} @ ${info.event.start}`
            );
        }

        setDutyId(event.id);
        setShowAssignerMenu(true);
    };

    return (
        <main
            className="fullPage"
            style={{ backgroundColor: "hsl(0, 0%, 96%)" }}
        >
            <AdminNavbar selected="home" />
            <section className="d-flex align-items-center">
                <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                    <Container>
                        <Calendar
                            timeGrid={true}
                            duration={1}
                            eventsRef={eventsRef}
                            eventClick={eventClick}
                        />
                    </Container>
                </div>
            </section>

            <Modal
                show={showAssignerMenu}
                onHide={() => setShowAssignerMenu(false)}
                size="lg"
                aria-labelledby="contained-modal-title-vcenter"
                centered
            >
                <Modal.Header closeButton>
                    <Modal.Title
                        id="contained-modal-title-vcenter"
                        className="text-center"
                    >
                        Assign Shift
                    </Modal.Title>
                </Modal.Header>
                <Modal.Body className="text-center">
                    <ShiftAssignerMenu
                        dutyId={dutyId}
                    />
                </Modal.Body>
                <Modal.Footer>
                    <Button
                        variant="danger"
                        onClick={() => setShowAssignerMenu(false)}
                    >
                        Close
                    </Button>
                </Modal.Footer>
            </Modal>
        </main>
    );
}

export default AdminCalendar;
