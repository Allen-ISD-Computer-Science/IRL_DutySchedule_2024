import React, { useState } from "react";
import { Button } from "react-bootstrap";

import Container from "react-bootstrap/Container";

function ShiftAssignerMenu(props) {
    const [didRequestURL, setDidRequestURL] = useState("");

    const [shiftInfo, setShiftInfo] = useState({});

    React.useEffect(() => {
        const getData = (info) => {
            const requestURL = `${process.env.PUBLIC_URL}/adminPanel/duties/${props.shiftId}`;
            if (didRequestURL === requestURL) return;
            setDidRequestURL(requestURL);
    
            fetch(`${process.env.PUBLIC_URL}/adminPanel/duties/${props.shiftId}`, {
                headers: {
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
                method: "POST",
            })
                .then((response) => response.json())
                .then((json) => {
                    setShiftInfo(json);
                });
        };

        getData();
    }, [didRequestURL, props.shiftId]);
    
    return (
        <Container className="d-flex justify-content-between align-items-stretch p-2">
            <Container className="row" style={{ overflow: "hidden", maxHeight: "89.5vh" }}>
                <Container className="col">
                    <h2>Teachers On Duty</h2>
                    <hr />
                    {
                        shiftInfo?.onDuty?.map((teacher, i) => {
                            return (
                                <Container key={i} className="teacher" id={`teacher-${i}`} data-event={`{ "title": "${teacher.dutyName} - ${teacher.locationName}", "duration": '${shiftInfo.duration}" }`}>
                                    <h3>{teacher.name}</h3>
                                </Container>
                            );
                        })
                    }
                </Container>
                <Container className="col">
                    <Button variant="primary" className="w-50">Email All</Button>
                </Container>
            </Container>
            <Container className="row" style={{ overflow: "hidden", maxHeight: "89.5vh" }}>
                <Container className="col">
                    <h2>Teachers Available</h2>
                    <hr />
                    {
                        shiftInfo?.available?.map((teacher, i) => {
                            return (
                                <Container key={i} className="teacher" id={`teacher-${i}`} data-event={`{ "title": "${teacher.dutyName} - ${teacher.locationName}", "duration": '${shiftInfo.duration}" }`}>
                                    <h3>{teacher.name}</h3>
                                </Container>
                            );
                        })
                    }
                </Container>
                <Container className="col">
                    {/* Search Bar */}
                    <Container className="w-100 p-2">
                        <input type="text" className="w-90" placeholder="Search..." />
                        <Button variant="primary" className="w-10">🔍</Button>
                    </Container>
                </Container>
            </Container>
        </Container>
    );

}

export default ShiftAssignerMenu;