import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

function NavbarComponent() {
  return (
    <Navbar bg="primary" data-bs-theme="dark">
        <Container>
            <Navbar.Brand href="./dashboard">AHS DutyDashboard</Navbar.Brand>
            <Nav className="me-auto">
                <Nav.Link href="#">Home</Nav.Link>
            </Nav>
        </Container>
    </Navbar>
  );
}

export default NavbarComponent;
