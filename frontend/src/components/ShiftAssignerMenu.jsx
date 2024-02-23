import React, { useState } from "react";
import { Button } from "react-bootstrap";

import Container from "react-bootstrap/Container";

function ShiftAssignerMenu(props) {
    const [didRequestURL, setDidRequestURL] = useState("");

    const [assignedUsers, setAssignedUsers] = useState([]);
    const [availableUsers, setAvailableUsers] = useState([]);
    const [filter, setFilter] = useState("");

    const updateFilter = () => {
        const available = document.querySelectorAll(".teacherAvailable");
        available.forEach((ele, i) => {
            if (
                !ele.innerText
                    .toLowerCase()
                    .includes(filter.toLowerCase())
            ) {
                ele.classList.add("d-none");
            } else {
                ele.classList.remove("d-none");
            }
        });
    };

    React.useEffect(() => {
        const getData = (info) => {
            const requestURL = `${process.env.PUBLIC_URL}/adminPanel/shiftUsers/${props.shiftId}`;
            if (didRequestURL === requestURL) return;
            setDidRequestURL(requestURL);

            fetch(`${process.env.PUBLIC_URL}/adminPanel/shiftUsers/data`, {
                headers: {
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
                method: "POST",
                body: JSON.stringify({
                    shiftExternalIDText: props.shiftId,
                }),
            })
                .then((response) => response.json())
                .then((json) => {
                    setAssignedUsers(json);
                });

            fetch(
                `${process.env.PUBLIC_URL}/adminPanel/usersWithMatchingAvailabilityForShift/data`,
                {
                    headers: {
                        Accept: "application/json",
                        "Content-Type": "application/json",
                    },
                    method: "POST",
                    body: JSON.stringify({
                        shiftExternalIDText: props.shiftId,
                    }),
                }
            )
                .then((response) => response.json())
                .then((json) => {
                    setAvailableUsers(json);
                });
        };

        getData();
    }, [didRequestURL, props.shiftId]);

    const assignTeacher = async (e) => {
        console.log(e);

        const externalUserID = e.currentTarget.id.split("_")[1];

        fetch(`${process.env.PUBLIC_URL}/adminPanel/addShift`, {
            headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
            },
            method: "POST",
            body: JSON.stringify({
                shiftExternalIDText: props.shiftId,
                userExternalIDText: externalUserID,
            }),
        })
            .then((response) => response.json())
            .then((json) => {
                console.log(json);

                setAssignedUsers([
                    ...assignedUsers,
                    availableUsers.find(
                        (a) => a.externalIDText == externalUserID
                    ),
                ]);
                setAvailableUsers(
                    availableUsers.filter(
                        (a) => a.externalIDText != externalUserID
                    )
                );
            });
    };

    return (
        <Container className="d-flex justify-content-between align-items-stretch p-2">
            <Container
                className="row"
                style={{ overflow: "hidden", maxHeight: "89.5vh" }}
            >
                <Container className="col">
                    <h2>Teachers On Duty</h2>
                    <hr />
                    {assignedUsers.map((teacher, i) => {
                        return (
                            <Container
                                key={i}
                                className="teacher"
                                id={`teacher_${teacher.externalIDText}`}
                            >
                                <h3>
                                    {teacher.firstName} {teacher.lastName}
                                </h3>
                            </Container>
                        );
                    })}
                </Container>
                <Container className="col">
                    <Button variant="primary" className="w-50">
                        Email All
                    </Button>
                </Container>
            </Container>
            <Container
                className="row"
                style={{ overflow: "hidden", maxHeight: "50vh" }}
            >
                <Container
                    className="col"
                    style={{ maxHeight: "100%", overflow: "none" }}
                >
                    <h2>Teachers Available</h2>
                    {/* Search Bar */}
                    <Container className="w-100 p-2 flex justify-content align-center">
                        <input
                            type="text"
                            className="w-90"
                            style={{ marginRight: 10 }}
                            value={filter}
                            onChange={(e) => setFilter(e.currentTarget.value)}
                            onKeyDown={(e) => {
                                if (e.key === "Enter") updateFilter();
                            }}
                            placeholder="Search..."
                        />
                        <Button
                            variant="primary"
                            className="ml-4 w-10"
                            onClick={updateFilter}
                        >
                            🔍
                        </Button>
                    </Container>

                    <hr />
                    <Container style={{ display: "flex", flexDirection: "column", gap: "0.5rem", height: "100%", overflowY: "auto" }}>
                        {availableUsers.map((teacher, i) => {
                            return (
                                <Button
                                    key={i}
                                    className="teacher teacherAvailable"
                                    onClick={(e) => {
                                        assignTeacher(e);
                                    }}
                                    id={`teacher_${teacher.externalIDText}`}
                                >
                                    {teacher.firstName} {teacher.lastName}
                                </Button>
                            );
                        })}
                    </Container>
                </Container>
            </Container>
        </Container>
    );
}

export default ShiftAssignerMenu;
