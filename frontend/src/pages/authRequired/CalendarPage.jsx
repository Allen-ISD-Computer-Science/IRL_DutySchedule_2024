import React from "react";
import { Container } from "react-bootstrap";

import Navbar from "../../components/Navbar";
import Calendar from "../../components/Calendar";
import EventModal from "../../components/EventModal";

function CalendarPage() {
    const [eventModalVisibility, setEventModalVisibility] =
        React.useState(false);
    const [eventName, setEventName] = React.useState("");
    const [eventDate, setEventDate] = React.useState("");
    const [eventStartTime, setEventStartTime] = React.useState("");
    const [eventEndTime, setEventEndTime] = React.useState("");
    const [eventLocation, setEventLocation] = React.useState("");
    const [eventLocationDesc, setEventLocationDesc] = React.useState("");

    const showEventModal = () => setEventModalVisibility(true);
    const hideEventModal = () => setEventModalVisibility(false);

    const eventsRef = React.useRef({});

    const getTime = (time) => {
        const d = new Date();
        d.setHours(...time.split(":").map((a) => parseInt(a)));
        return d.toLocaleTimeString();
    };

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

        setEventName(event.dutyName);
        setEventDate(
            new Date(event.day).toLocaleDateString("en-us", {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
            })
        );
        setEventStartTime(getTime(event.startTime));
        setEventEndTime(getTime(event.endTime));
        setEventLocation(event.locationName);
        setEventLocationDesc(event.locationDescription);
        showEventModal();
    };

    return (
        <main
            className="fullPage"
            style={{ backgroundColor: "hsl(0, 0%, 96%)" }}
        >
            <Navbar />
            <section className="d-flex align-items-center">
                <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                    <Container>
                        <Calendar
                            eventsRef={eventsRef}
                            eventClick={eventClick}
                        />
                    </Container>
                </div>
            </section>

            <EventModal
                eventNameRef={eventName}
                eventStartDateRef={eventDate}
                eventStartTimeRef={eventStartTime}
                eventEndTimeRef={eventEndTime}
                eventLocationRef={eventLocation}
                eventLocationDescRef={eventLocationDesc}
                showModal={eventModalVisibility}
                onHide={hideEventModal}
            />
        </main>
    );
}

export default CalendarPage;
