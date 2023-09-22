
import React from 'react';
import { Form, Button, Container } from 'react-bootstrap';

import AdminNavbar from '../../components/AdminNavbar'

function Upload() {
    return (
        <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
            <AdminNavbar selected="upload" />
            <section className="d-flex align-items-center">
                <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                    <Container>
                        <Form action='./upload' method="POST" enctype="multipart/form-data">
                            <Form.Group className="mb-3" controlId="formBasicEmail">
                                <Form.Label>CSV File</Form.Label>
                                <Form.Control type="file" placeholder="Select file" accept='.csv' />
                                <Form.Text className="text-muted">
                                    Upload the properly formatted CSV file.
                                </Form.Text>
                            </Form.Group>

                            <Button variant="primary" type="submit">
                                Submit
                            </Button>
                            <br />
                            <Form.Text className="text-muted">
                                Once submitted, please wait a few moments for the CSV file to be processed.
                            </Form.Text>
                        </Form>
                    </Container>
                </div>
            </section>
        </main>
    );
}

export default Upload;
