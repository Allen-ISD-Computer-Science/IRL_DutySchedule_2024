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

	console.log(info.event.id);

        const event = eventsRef.current.find((a) => a.shiftExternalIDText === info.event.id);

        if (!event) {
            throw new Error(
                `Couldn't find event: ${info.event.title} @ ${info.event.start}`
            );
        }

        setDutyId(event.shiftExternalIDText);
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
			    isAdmin={true}
                            timeGrid={true}
                            duration={2}
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
                        shiftId={dutyId}
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
