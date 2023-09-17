import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

import './index.css';
import 'bootstrap/dist/css/bootstrap.min.css';

import ErrorPage from "./pages/ErrorPage";
import SignIn from './pages/SignIn';
import SignUp from './pages/SignUp';
import UpdateAccount from './pages/UpdateAccount';

import Dashboard from './pages/Dashboard';

import Admin from './pages/Admin';

const router = createBrowserRouter([
  {
    path: "/",
    errorElement: <ErrorPage />,
  },
  {
    path: "/signin",
    element: <SignIn />,
  },
  {
    path: "/signup",
    element: <SignUp />,
  },
  {
    path: "/updateAccount",
    element: <UpdateAccount />,
  },
  {
    path: "/updateAccount/*",
    element: <UpdateAccount />,
  },
  {
    path: "/admin",
    element: <Admin />,
  },
  {
    path: "/dashboard",
    element: <Dashboard />,
  },
],
{
  basename: process.env.PUBLIC_URL ? `${process.env.PUBLIC_URL}/` : "/",
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
