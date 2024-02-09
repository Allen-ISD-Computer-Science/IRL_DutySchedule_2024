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
	    if (!ele.firstChild.innerText.toLowerCase().includes(filter.toLowerCase())) {
		ele.classList.add("d-none");
	    } else {
		ele.classList.remove("d-none");
	    }
	});
    }
    
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
		    shiftExternalIDText: props.shiftId
		})
            })
                .then((response) => response.json())
                .then((json) => {
                    setAssignedUsers(json);
                });

	    fetch(`${process.env.PUBLIC_URL}/adminPanel/usersWithMatchingAvailabilityForShift/data`, {
                headers: {
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
                method: "POST",
		body: JSON.stringify({
		    shiftExternalIDText: props.shiftId
		})
            })
                .then((response) => response.json())
                .then((json) => {
                    setAvailableUsers(json);
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
                        assignedUsers.map((teacher, i) => {
                            return (
                                <Container key={i} className="teacher" id={`teacher-${i}`}>
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
                        availableUsers.map((teacher, i) => {
                            return (
                                <Container key={i} className="teacher teacherAvailable" id={`teacher-${i}`}>
                                    <h3>{teacher.name}</h3>
                                </Container>
                            );
                        })
                    }
                </Container>
                <Container className="col">
                    {/* Search Bar */}
                    <Container className="w-100 p-2">
                        <input type="text" className="w-90"
			       value={filter}
			       onChange={(e) =>
                                   setFilter(
                                       e.currentTarget.value
                                   )
                               }
			       placeholder="Search..." />
                        <Button variant="primary" className="ml-4 w-10" onClick={updateFilter}>🔍</Button>
                    </Container>
                </Container>
            </Container>
        </Container>
    );

}

export default ShiftAssignerMenu;
