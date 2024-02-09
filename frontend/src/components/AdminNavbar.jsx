import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';


function AdminNavbarComponent(props) {
  const selected = props?.selected || "";

  return (
    <Navbar bg="primary" data-bs-theme="dark">
        <Container>
            <Navbar.Brand href={process.env.PUBLIC_URL + "/adminPanel"}>AHS DutyDashboard | Admin</Navbar.Brand>
            <Nav className="me-auto">
                <Nav.Link href={process.env.PUBLIC_URL + "/adminPanel"}>Home</Nav.Link>
                <Nav.Link href={process.env.PUBLIC_URL + "/adminPanel/upload"}>Upload</Nav.Link>
                <Nav.Link href={process.env.PUBLIC_URL + "/adminPanel/calendar"}>Calendar</Nav.Link>
            </Nav>
        </Container>
    </Navbar>
  );
}

export default AdminNavbarComponent;


