import React, { useEffect } from 'react'
window.React = React

import ReactDOM from 'react-dom/client';
/* import PageController from '@Core/NuiController/PageController'; */


import './NuiStyles/App.css';
import ObjectsSystem from '../ObjectsSystem'
import Utilities from '../Utilities';


const root = ReactDOM.createRoot(document.getElementById('root')!);


root.render(
   <div className='w-screen h-screen '>
      <div className='w-full h-full absolute '>
         <Utilities />
      </div>
      <div className='w-full h-full absolute  '>
         <ObjectsSystem />
      </div>
   </div>);


