// Script.js
const sortableList = document.querySelector(".sortable-list");
const items = sortableList.querySelectorAll(".item");

let newId = -1;

items.forEach(item => {
    item.addEventListener("dragstart", () => setTimeout(() => item.classList.add("dragging"), 0));
    item.addEventListener("dragend", () => {
        item.classList.remove("dragging");
        changeId(item.getAttribute("data-value"), newId)
        .then((data) => location.reload())
        .catch(error => {
            console.log(error);
        });
    });
});

const initSortableList = (e) => {
    e.preventDefault();
    const draggingItem = document.querySelector(".dragging");
    let siblings = [...sortableList.querySelectorAll(".item:not(.dragging)")];
    let nextSibling = siblings.find(sibling => e.clientY <= sibling.offsetTop + sibling.offsetHeight / 2);
    newId = siblings.indexOf(nextSibling);
    newId = newId != -1 ? newId : (siblings.length);
    sortableList.insertBefore(draggingItem, nextSibling);
}

const changeId = async (MAC_ADDRESS, newId)=>{
    const response = await fetch("./move", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body : JSON.stringify({MAC_ADDRESS, newId})
    });
    return response.json();
}

sortableList.addEventListener("dragover", initSortableList);
sortableList.addEventListener("dragenter", e => e.preventDefault());