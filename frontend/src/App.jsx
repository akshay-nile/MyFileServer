import { useState, useEffect } from "react";
import { fetchItemsInfo } from "./services/apiService";


function App() {
  const [deviceInfo, setDeviceInfo] = useState({ device: { hostname: null, platform: null }, drives: [] });
  const [itemsInfo, setItemsInfo] = useState({ folders: [], files: [] });
  const [breadCrumb, setBreadCrumb] = useState([]);

  useEffect(() => { loadDeviceInfo(); });

  async function loadDeviceInfo() {
    setDeviceInfo(await fetchItemsInfo('/'));
    setItemsInfo({ folders: [], files: [] });
    setBreadCrumb(breadCrumb.map(b => { return { ...b, visible: false }; })); // Make all invisible
  }

  async function loadItemsInfo(path, label = null) {
    setItemsInfo(await fetchItemsInfo(path));
    deviceInfo.drives.length && setDeviceInfo({ ...deviceInfo, drives: [] });

    if (label) {
      const i = breadCrumb.findIndex(bi => !bi.visible); // Index of the first invisible item, -1 if not found
      const newItem = { label, path, visible: true };
      const newBreadCrumb = i !== -1 ? breadCrumb.slice(0, i) : breadCrumb;
      setBreadCrumb([...newBreadCrumb, newItem]); // Delete all invisible items, since new path is choosen
    }
  }

  function goBackToItemAt(i) {
    for (let bi = i + 1; bi < breadCrumb.length; bi++) breadCrumb[bi].visible = false;
    i === -1 ? loadDeviceInfo() : loadItemsInfo(breadCrumb[i].path);
    setBreadCrumb(breadCrumb);
  }

  function traverseBreadCrumbBy(step) {
    const currentVisibleIndex = breadCrumb.filter(b => b.visible).length - 1; // Index of the last visible item, -1 if nothing visible
    const firstInvisibleIndex = breadCrumb.findIndex(b => !b.visible); // Index of the first invisible item, -1 if not found

    if (step === 1) {
      if (firstInvisibleIndex === -1) return; // There's no invisible item in history to go forward
      breadCrumb[firstInvisibleIndex].visible = true;
      loadItemsInfo(breadCrumb[firstInvisibleIndex].path);
      setBreadCrumb(breadCrumb);
    }

    if (step === -1) {
      if (currentVisibleIndex === -1) return; // There's no more visible items to go backward
      if (currentVisibleIndex === 0) loadDeviceInfo();
      else goBackToItemAt(currentVisibleIndex - 1);
    }
  }

  return (
    <div className="fullwindow">
      <div className="button-panel">
        <button onClick={() => traverseBreadCrumbBy(-1)}>{'<<'} Backward</button>
        <button onClick={() => traverseBreadCrumbBy(1)}>Forward {'>>'}</button>
      </div>

      <div className="app no-select">
        {
          <div>
            <h3 className="hostname">
              <a href="#" onClick={() => goBackToItemAt(-1)}>{deviceInfo.device.hostname}&nbsp; {(breadCrumb.find(b => b.visible)) && '>>'} &nbsp;</a>
            </h3>
            <h3 className="breadcrumb">
              {breadCrumb.filter(b => b.visible).map((b, i) => <a href="#" key={i} onClick={() => goBackToItemAt(i)}>{b.label} {(i < breadCrumb.length - 1) && ' / '}</a>)}
            </h3>
          </div>
        }

        {
          <ul>
            {deviceInfo.drives.map((drive) =>
              <li key={drive.label} onClick={() => loadItemsInfo(drive.path, deviceInfo.device.platform === 'Windows' ? drive.letter + ':' : drive.label)}>
                <h3 className="itemlabel">{(drive.letter ? drive.letter + ': ' : '') + drive.label}</h3>
                <span className="iteminfo gray">
                  Free: {drive.size.free} | Used: {drive.size.used} | Total: {drive.size.total}
                </span>
              </li>
            )}
          </ul>
        }

        {
          <ul>
            {itemsInfo.folders.map((folder) =>
              <li key={folder.name} onClick={() => loadItemsInfo(folder.path, folder.name)}>
                <h3 className="itemlabel">{folder.name}</h3>
                <span className="iteminfo gray">
                  Folders: {folder.size[0]} | Files: {folder.size[1]}
                </span>
              </li>
            )}
          </ul>
        }

        {
          <ul>
            {itemsInfo.files.map((file) =>
              <li key={file.name}>
                <h3 className="itemlabel gray">{file.name}</h3>
                <span className="iteminfo gray">
                  File Size: {file.size}
                </span>
              </li>
            )}
          </ul>
        }
      </div>
    </div>
  );
}

export default App;
