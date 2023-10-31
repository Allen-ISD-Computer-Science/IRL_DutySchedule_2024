import { useEffect, useState } from 'react';

import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

function NavbarComponent() {
    const [showAdmin, setShowAdmin] = useState(false);
    
    useEffect(() => {
	fetch("./userPermission", {
	    method: "GET"
	}).then(response => {
	    setShowAdmin(!!response)
	});
    }, []);
    
  return (
    <Navbar bg="primary" data-bs-theme="dark">
        <Container>
            <Navbar.Brand href="./dashboard">AHS DutyDashboard</Navbar.Brand>
            <Nav className="me-auto">
                <Nav.Link href="./dashboard">Dashboard</Nav.Link>
                <Nav.Link href="./calendar">Calendar</Nav.Link>
            </Nav>

	        <Nav className="ml-auto" style={{display: showAdmin ? "block" : "none"}}>
                <Nav.Link href="./adminPanel">Admin</Nav.Link>
            </Nav>
        </Container>
    </Navbar>
  );
}

export default NavbarComponent;
