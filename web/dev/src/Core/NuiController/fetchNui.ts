
import { isEnvBrowser } from "./misc";
import axios from 'axios'


export async function fetchNui<T = any>(eventName: string, data?: any, mockData?: T): Promise<T> {
  const dataStr = data ? JSON.stringify(data) : ''
  
  try {
    if (isEnvBrowser() && mockData) return mockData;
    const resourceName = (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'nui-frame-app';
    const timeoutMs = 2000; // Defina o tempo limite em milissegundos (por exemplo, 2 segundos).

    const response = await axios.post(`https://${resourceName}/${eventName}`, dataStr, {
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      timeout: timeoutMs,
    });

    if (response.status === 200) {
      const responseData = response.data;
      return responseData
    } else {
      return Promise.reject(` Resposta com erro HTTP: ${eventName} ${dataStr}  ${response.status}   `,);
    }

  } catch (error) {
    return Promise.reject('ERRO NA REQUISIÇÃO NUI ' + ` ${eventName} ${dataStr}  error ${error} `,);
  }

}


