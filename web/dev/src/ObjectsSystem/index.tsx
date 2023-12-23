import React, { Suspense, useRef, useState, useEffect } from "react";
import { Canvas, useThree } from "@react-three/fiber";
import { TransformControls, PerspectiveCamera } from "@react-three/drei";
import { Mesh, MathUtils } from "three";
import { useNuiEvent } from "@Core/NuiController/useNuiEvent";
import { fetchNui } from "@Core/NuiController/fetchNui";
import { useKeyPressEvent } from "react-use";
import { isEnvBrowser } from "@Core/NuiController/misc";

const ENV_BROWSER = isEnvBrowser()


type cds = { x: number, y: number, z: number }
interface camProps {
    position?: cds,
    rotation?: cds
}
interface objectProps {
    position?: cds,
    rotation?: cds,
    showNui?: boolean
}
type editorType = "translate" | "rotate" | undefined
const deg = MathUtils.degToRad

const CameraComponent = () => {
    const { camera } = useThree();


    const zRotationHandler = (angle: number, rotationValue: number): number => {
        const validateAngle = (angle > 0 && angle < 90)
        if (validateAngle) {
            return rotationValue
        }

        if ((angle > -180 && angle < -90) || (angle > 0)) {
            return -rotationValue
        }

        return rotationValue
    };



    useNuiEvent("props:setcam", ({ position, rotation }) => {
        camera.position.set(position.x, position.z, -position.y);
        camera.rotation.order = "YZX";

        rotation &&
            camera.rotation.set(
                MathUtils.degToRad(rotation.x),
                MathUtils.degToRad(zRotationHandler(rotation.x, rotation.z)),
                MathUtils.degToRad(rotation.y)
            );

        camera.updateProjectionMatrix();
    });

    return (
        <PerspectiveCamera
            position={[0, 0, 10]}
            makeDefault
            onUpdate={(e) => e.updateProjectionMatrix()}
        />
    );
};

const TransformComponent = () => {
    const mesh = useRef<Mesh>(null!);
    const [mode, setMode] = useState<editorType>("translate");
    const [nuiVisible, setNuiVisible] = useState<boolean>(ENV_BROWSER);

    const objectChange = () => {
        const meshData = mesh.current;
        if (meshData) {
            const nuiData: camProps = {
                position: {
                    x: meshData.position.x,
                    y: -meshData.position.z,
                    z: meshData.position.y,
                },
                rotation: {
                    x: MathUtils.radToDeg(meshData.rotation.x),
                    y: MathUtils.radToDeg(-meshData.rotation.z),
                    z: MathUtils.radToDeg(meshData.rotation.y),
                },
            };
            fetchNui('updateObject', nuiData).catch(() => { return })
        }
    };

    useNuiEvent<objectProps>("props:setObject", ({ position, rotation, showNui }) => {
        if (showNui != null || showNui != undefined) {
            if (showNui) {
                setNuiVisible(true)
            } else {
                setNuiVisible(false)
            }
        }
        if (position) {
            mesh.current.position.set(position.x, position.z, -position.y)
        }
        if (rotation) {
            mesh.current.rotation.order = "YZX";
            mesh.current.rotation.set(
                deg(rotation.x),
                deg(rotation.z),
                deg(rotation.y)
            );
        }
    });

    const close = () => {
        if (nuiVisible) {
            setMode("translate")
            setNuiVisible(false)
            fetchNui("props:close").catch(() => { return })
        }
    }

    const cancel = () => {
        if (nuiVisible) {
            setMode("translate")
            fetchNui("props:cancel").catch(() => { return })
            close()
        }
    }




    const toggle = () => {
        if (nuiVisible) {
            if (mode == 'rotate') {
                setMode("translate")
            } else {
                setMode("rotate")
            }
        }
    }


    useKeyPressEvent('Backspace', cancel)
    useKeyPressEvent('Enter', close)
    useKeyPressEvent('r', toggle)

    if(!ENV_BROWSER) {
        useKeyPressEvent('Escape', cancel)
    }

    return (
        <>
            {nuiVisible && <TransformControls
                size={0.5}
                object={mesh}
                mode={mode}
                onObjectChange={objectChange}
            />
            }
            <mesh ref={mesh} />
        </>
    );
};

const ThreeComponent = () => {
    return (
        <Canvas style={{ zIndex: 1 }}>
            <CameraComponent />
            <TransformComponent />
        </Canvas>
    );
};

export default ThreeComponent;
