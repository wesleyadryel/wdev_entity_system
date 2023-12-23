import { useNuiEvent } from "@Core/NuiController/useNuiEvent";
import { Alert } from "flowbite-react";
import React, { useState } from "react";


const NuiUtilities = () => {
    const [alert, setAlert] = useState<string | undefined>(undefined);
    const [timeout, setTimeout_] = useState<NodeJS.Timeout|undefined>(undefined);

    const copyTextToClipboard = (text: string) => {
        // Cria um elemento textarea temporário para copiar o texto para a área de transferência
        const textarea = document.createElement("textarea");
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        try {
            const successful = document.execCommand("copy");
            if (successful) {
                setAlert('Texto copiado para a área de transferência')
            }
        } catch (error) { return }
        document.body.removeChild(textarea);
    };

    useNuiEvent<string>("copyText", (text) => {
        copyTextToClipboard(text)
    })

    useNuiEvent<string>("alert", (text) => {
        setAlert(text)
        if(timeout) {
            clearTimeout(timeout)
        }
        const t = setTimeout(() => {
            setAlert(undefined)
        }, 4000)
        setTimeout_(t)
    })


    return <>
        {alert &&
            <div className="flex justify-center pt-8">
                <div className="transition-opacity ease-in duration-700 opacity-100 ">
                    <Alert color="success" >
                        <span className="font-medium">{alert}</span>
                    </Alert>
                </div>
            </div>
        }
    </>

}

export default NuiUtilities