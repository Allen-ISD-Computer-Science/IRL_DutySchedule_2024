import React from "react";
import { Container } from "react-bootstrap";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
    faCalendar,
    faClock,
    faMapPin,
    faClipboard,
    faBullhorn,
} from "@fortawesome/free-solid-svg-icons";

import "./calendar.css";

import Navbar from "../../components/Navbar";
import Calendar from "../../components/Calendar";
import EventModal from "../../components/EventModal";

function DashboardPage(props) {
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
        console.log(eventsRef.current);
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
                        <h2>Welcome {props.name || "User"}!</h2>
                        <br></br>
                        <Container className="shadow p-3 mb-5 bg-white rounded mt-4">
                            <h4>
                                <FontAwesomeIcon icon={faBullhorn} />{" "}
                                Announcements:
                            </h4>
                            <br></br>
                            <h3>
                                {" "}
                                {props.announcement ||
                                    " There is no school on 01/01/2025 "}
                            </h3>
                            <br></br>
                        </Container>

                        <Container className="shadow p-3 mb-5 bg-white rounded mt-4">
                            <h4> Your Next duty:</h4>
                            <br></br>
                            <h3>
                                <FontAwesomeIcon icon={faClipboard} />{" "}
                                {props.nextDutyName || " Bus Duty"}
                            </h3>
                            <br></br>
                            <p>
                                <FontAwesomeIcon icon={faCalendar} />{" "}
                                {props.nextDutyDate || " 01/02/2025"}
                            </p>
                            <p>
                                <FontAwesomeIcon icon={faClock} />{" "}
                                {props.nextDutyTime || " 4:00-5:00 PM"}
                            </p>
                            <p>
                                <FontAwesomeIcon icon={faMapPin} />{" "}
                                {props.nextDutyLocation || " PAC"}
                            </p>
                        </Container>

                        <Container className="shadow p-3 mb-5 bg-white rounded mt-4">
                            <Calendar
                                timeGrid={true}
                                eventsRef={eventsRef}
                                eventClick={eventClick}
                            />
                        </Container>
                    </Container>
                    <EventModal
                        eventNameRef={eventName}
                        eventStartDateRef={eventDate}
                        eventStartTimeRef={eventStartTime}
                        eventEndTimeRef={eventEndTime}
                        eventLocationRef={eventLocation}
                        showModal={eventModalVisibility}
                        onHide={hideEventModal}
                    />
                </div>
            </section>
        </main>
    );
}

export default DashboardPage;
