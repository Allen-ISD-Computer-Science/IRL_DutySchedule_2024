import React from "react";
import { Container } from "react-bootstrap";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
    faCalendar,
    faHourglassStart,
    faHourglassEnd,
    faMapPin,
} from "@fortawesome/free-solid-svg-icons";

import "./calendar.css";

import Navbar from "../../components/Navbar";
import Calendar from "../../components/Calendar";
import EventModal from "../../components/EventModal";
// RCE CSS
import 'react-chat-elements/dist/main.css'
import { ChatItem } from 'react-chat-elements'
import { AddToCalendarButton } from 'add-to-calendar-button-react';
function DashboardPage(props) {
    const [eventModalVisibility, setEventModalVisibility] =
        React.useState(false);
    const [eventName, setEventName] = React.useState("");
    const [eventDate, setEventDate] = React.useState("");
    const [eventStartTime, setEventStartTime] = React.useState("");
    const [eventEndTime, setEventEndTime] = React.useState("");
    const [eventLocation, setEventLocation] = React.useState("");
    const [eventLocationDesc, setEventLocationDesc] = React.useState("");
    const [nextDutyName, setNextDutyName] = useState('');
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
      const getData = (info) => {
        try {
          fetch(process.env.PUBLIC_URL + "/duties/user/count", {
    headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
    },
    method: "POST",
    body: JSON.stringify({
        from: info.start.toISOString().split("T")[0] + "T00:00:00Z",
        count: 1,
    }),
})
    .then((response) => response.json())
    .then((json) => {
            const retrieveNextDutyName = json.dutyName;
            setNextDutyName(retrieveNextDutyName);
            console.log("Retrieved next duty name:", retrieveNextDutyName);

             });
        } catch (err) {
            console.error(err);
        }
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
                       
                    <ChatItem
                    avatar={'data:image/png;base64,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'}
                    alt={'Message'}
                    title={'Announcement'}
                    subtitle= {props.announcement || " There is no school on 01/01/2025 "}
                    date={new Date()}
                    unread={1}
                    />

                        <Container className="shadow p-3 mb-5 bg-white rounded mt-4">
                            <h4> Your Next duty:</h4>

                          <Container>

                            <h3 >
                                 <b>{nextDutyName}</b>
                            </h3>
                            <br></br>
                            <p>
                                <FontAwesomeIcon icon={faCalendar} />{" "}
                                {props.nextDutyDate || " 01/02/2025"}
                            </p>
                            <p>
                                <FontAwesomeIcon icon={faHourglassStart} />{" "}
                                {props.nextDutyStartTime || " 4:00 PM"}
                            </p>
                             <p>
                                <FontAwesomeIcon icon={faHourglassEnd} />{" "}
                                {props.nextDutyEndTime || " 5:00 PM"}
                            </p>
                            <p>
                                <FontAwesomeIcon icon={faMapPin} />{" "}
                                {props.nextDutyLocation || " PAC"}
                            </p>
			    
                        
                                    
				
				</Container>
<AddToCalendarButton
  name= {props.nextDutyName || "Bus Duty"}
  options={['Outlook.com','Google','Apple', 'iCal']}
  location={props.nextDutyLocation || "PAC"}
  startDate={props.nextDutyDate || "2025-01-02"}
  startTime={props.nextDutyStartTime || "16:00"}
  endTime={props.nextDutyEndTime || "17:00"}
  timeZone="America/Chicago"
></AddToCalendarButton>
			</Container>

                        <Container className="shadow p-3 mb-5 bg-white rounded mt-4">
                            <Calendar
                                timeGrid={true}
                                eventsRef={eventsRef}
                                eventClick={eventClick}
                            />
                        </Container>
                    </Containe
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
                </div>
            </section>
        </main>
    );
}

export default DashboardPage;