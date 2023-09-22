import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

function AdminNavbarComponent(props) {
  const selected = props?.selected || "";

  return (
    <Navbar bg="primary" data-bs-theme="dark">
        <Container>
            <Navbar.Brand href="./adminPanel">AHS DutyDashboard | Admin</Navbar.Brand>
            <Nav className="me-auto">
                <Nav.Link href={selected === "home" ? "#" : "../adminPanel"}>Home</Nav.Link>
                <Nav.Link href={selected === "upload" ? "#" : "./adminPanel/upload"}>Upload</Nav.Link>
            </Nav>
        </Container>
    </Navbar>
  );
}

export default AdminNavbarComponent;
