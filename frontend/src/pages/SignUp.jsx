import { useState } from "react";

import Button from "react-bootstrap/Button";

function SignUp() {
    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [email, setEmail] = useState("");

    const sendAccountCreate = async (e) => {
        e.preventDefault();

        const response = await fetch("./createuser", {
            method: "POST",
            headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                firstName: firstName,
                lastName: lastName,
                email: email,
            }),
        });

        response.json().then((data) => {
            if (data.reason) {
                alert(data.reason);
            } else {
                alert(data.error);
            }
        });
    };

    return (
        <section
            className="fullPage d-flex align-items-center"
            style={{ backgroundColor: "hsl(0, 0%, 96%)" }}
        >
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <div className="container">
                    <div className="row gx-lg-5 align-items-center">
                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <h1 className="my-5 display-3 fw-bold ls-tight">
                                Allen High School <br />
                                <span className="text-primary">
                                    Conferences App
                                </span>
                            </h1>
                            <p style={{ color: "hsl(217, 10%, 50.8%)" }}>
                                The go-to app for educators who want to
                                streamline their daily routines, reduce stress,
                                and maximize productivity. Say goodbye to the
                                chaos of managing your duties and hello to a
                                more organized and efficient teaching
                                experience! Start using today to simplify your
                                teaching life.
                            </p>
                        </div>

                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <div className="card">
                                <div className="card-body py-5 px-md-5">
                                    <form onSubmit={sendAccountCreate}>
                                        <div className="form-outline mb-4">
                                            <input
                                                type="text"
                                                id="signUpFirstName"
                                                className="form-control"
                                                value={firstName}
                                                onChange={(e) =>
                                                    setFirstName(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="signUpFirstName"
                                            >
                                                First Name
                                            </label>
                                        </div>

                                        <div className="form-outline mb-4">
                                            <input
                                                type="text"
                                                id="signUpLastName"
                                                className="form-control"
                                                value={lastName}
                                                onChange={(e) =>
                                                    setLastName(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="signUpLastName"
                                            >
                                                Last Name
                                            </label>
                                        </div>

                                        <div className="form-outline mb-4">
                                            <input
                                                type="email"
                                                id="signUpEmail"
                                                className="form-control"
                                                value={email}
                                                onChange={(e) =>
                                                    setEmail(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="signUpEmail"
                                            >
                                                Email address
                                            </label>
                                        </div>

                                        <Button
                                            varient="primary"
                                            className="btn-block mb-4"
                                            type="submit"
                                        >
                                            Sign Up
                                        </Button>

                                        <div className="text-center">
                                            <p>Already have an account?</p>
                                            <a href="./signin">Sign In</a>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
}

export default SignUp;
