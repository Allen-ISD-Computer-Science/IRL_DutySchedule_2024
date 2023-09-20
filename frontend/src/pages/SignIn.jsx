import { useState } from "react";

import Button from "react-bootstrap/Button";

function SignIn() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");

    const sendLogin = async (e) => {
        e.preventDefault();

        const user = document.getElementById("signInEmail").value,
            pass = document.getElementById("signInPassword").value;
        const formBody = new URLSearchParams();
        formBody.append("username", user);
        formBody.append("password", pass);
        const response = await fetch("./login", {
            method: "POST",
            headers: {
                Accept: "application/json",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            body: formBody.toString(),
        });

        response.json().then((data) => {
            if (data.reason) {
                alert(data.reason);
            } else if (data.error === "Success") {
                window.location.href = process.env.PUBLIC_URL + "/dashboard";
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
                                    Duty Dashboard
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
                                    <form onSubmit={sendLogin}>
                                        <div className="form-outline mb-4">
                                            <input
                                                type="email"
                                                id="signInEmail"
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
                                                htmlFor="signInEmail"
                                            >
                                                Email address
                                            </label>
                                        </div>

                                        <div className="form-outline mb-4">
                                            <input
                                                type="password"
                                                id="signInPassword"
                                                className="form-control"
                                                value={password}
                                                onChange={(e) =>
                                                    setPassword(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="signInPassword"
                                            >
                                                Password
                                            </label>
                                        </div>

                                        <Button
                                            varient="primary"
                                            className="btn-block mb-4"
                                            type="submit"
                                        >
                                            Sign In
                                        </Button>

                                        <div className="row">
                                            <div className="col text-center">
                                                <p>Don't have an account?</p>
                                                <a href="./signup">Sign Up</a>
                                            </div>

                                            <div className="col text-center">
                                                <p>Can't remember your password?</p>
                                                <a href="./forgot">Forgot Password</a>
                                            </div>
                                        </div>

                                        {/*
                        <div className="text-center">
                            <p>or sign in with:</p>
                            <button type="button" className="btn btn-link btn-floating mx-1">
                                <FontAwesomeIcon icon={faGoogle} />
                            </button>
                            </div>
					 */}
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

export default SignIn;
