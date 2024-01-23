import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';

import parse from 'html-react-parser';

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCalendar, faClock, faMapPin } from '@fortawesome/free-solid-svg-icons'

function EventModal(props) {
  return (
    <Modal
	show={props.showModal}
      size="lg"
      aria-labelledby="contained-modal-title-vcenter"
      onHide={props.onHide}
      centered
    >
     <Modal.Header closeButton>
         <Modal.Title id="contained-modal-title-vcenter">
	     {props.eventNameRef}
        </Modal.Title>
      </Modal.Header>
	<Modal.Body>
            <p><FontAwesomeIcon icon={faCalendar} /> {props.eventStartDateRef}</p>
            <p><FontAwesomeIcon icon={faClock} /> {props.eventStartTimeRef} - {props.eventEndTimeRef}</p>
            <p><FontAwesomeIcon icon={faMapPin} /> {props.eventLocationRef}</p>
            <details>
              <summary>Description</summary>
              {parse(props.eventLocationDescRef)}
            </details>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={props.onHide}>Close</Button>
      </Modal.Footer>
    </Modal>
  );
}

export default EventModal;
