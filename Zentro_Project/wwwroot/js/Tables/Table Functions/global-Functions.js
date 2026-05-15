
function getQuantity(rowNo) {

    //target the inventory cell
    var row = $(`tbody tr:eq(${rowNo}) .editInput`)[1]

    //getting the text from the cell
    var cellText = $(row).text()

    //getting the first number out the string using regex
    var quantity = cellText.match(/\d+/)[0];

    //setting the value within the table
    $(row).text(quantity);
}


//Generate select options Html
function listGenerate(contentList, cellSelected, td) {

    //looping through the given list
    for (var i = 0; i < contentList.length; i++) {
        var opt = contentList[i];
        var elements = document.createElement("option");
        elements.textContent = opt.listValue;
        elements.value = opt.listId;

        //if the option is selected we set the attribute to selected
        if (opt.listValue == cellSelected) {
            elements.setAttribute('selected', true)
        }

        //append the attribute to the chosen parent
        td.appendChild(elements);
    }
}


//Generate select options Html with default select
function selectListGenerate(listType, id) {

    //empty the html element
    $(`#${id}`).empty();

    //Create a empty array
    var array = [];

    var record = { listValue: "Select", listId: 0 };

    listType.splice(0, 0, record);

    //Loop through the array 
    for (var i = 0; i < listType.length; i++) {
        var obj = listType[i];
        var element = document.createElement('option');
        element.textContent = obj.listValue;
        element.value = obj.listId;

        //push to the empty array 
        array.push(element)

    }
    //append to the html element
    $(`#${id}`).append(array)
}



//Generate select options Html with default select for country list
function selectListGenerateSwapped(listType, id) {

    //empty the html element
    $(`#${id}`).empty();

    //Create a empty array
    var array = [];

    var record = { listName: "Select", listValue: 0 };

    listType.splice(0, 0, record);

    //Loop through the array 
    for (var i = 0; i < listType.length; i++) {
        var obj = listType[i];
        var element = document.createElement('option');
        element.textContent = obj.listName;
        element.value = obj.listValue;

        //push to the empty array 
        array.push(element)

    }
    //append to the html element
    $(`#${id}`).append(array)
}


//Generate Option Html Select using the listname and value
function selectListGenerateInverse(listType, id, selectedVal = 0) {

    //empty the html element
    $(`#${id}`).empty();

    //Create a empty array
    var array = [];

    //Loop through the array 
    for (var i = 0; i < listType.length; i++) {
        var obj = listType[i];
        var element = document.createElement('option');
        element.textContent = obj.listName;
        element.value = obj.listValue;

        if (obj.listValue == selectedVal) {
            element.selected = true
        }


        //push to the empty array 
        array.push(element)

    }
    //append to the html element
    $(`#${id}`).append(array)
}