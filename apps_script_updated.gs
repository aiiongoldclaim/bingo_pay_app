const SHEET_NAME = "Products";
const ORDERS_SHEET_NAME = "Orders";
const ORDER_ITEMS_SHEET_NAME = "OrderItems";

function doGet(e) {
  try {
    const action = e.parameter.action;

    if (action === "getProducts") {
      return getProducts();
    }

    if (action === "getProduct") {
      return getProduct(e.parameter.product_id);
    }

    if (action === "getOrders") {
      return getOrders();
    }

    if (action === "getOrder") {
      return getOrder(e.parameter.order_id);
    }

    return jsonResponse({
      success: false,
      message: "Invalid action"
    });

  } catch (err) {
    return jsonResponse({
      success: false,
      message: err.toString()
    });
  }
}

function doPost(e) {
  try {
    const action = e.parameter.action;

    if (action === "addProduct") {
      const body = JSON.parse(e.postData.contents);
      return addProduct(body);
    }

    if (action === "addOrder") {
      const body = JSON.parse(e.postData.contents);
      return addOrder(body);
    }

    if (action === "updateOrderStatus") {
      const body = JSON.parse(e.postData.contents);
      return updateOrderStatus(body);
    }

    return jsonResponse({
      success: false,
      message: "Invalid action"
    });

  } catch (err) {
    return jsonResponse({
      success: false,
      message: err.toString()
    });
  }
}

function getProducts() {
  const sheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(SHEET_NAME);

  const data = sheet.getDataRange().getValues();

  if (data.length <= 1) {
    return jsonResponse({
      success: true,
      data: []
    });
  }

  const headers = data[0];

  const products = data
    .slice(1)
    .map(row => {
      const obj = {};

      headers.forEach((header, index) => {
        obj[header] = row[index];
      });

      return obj;
    });

  return jsonResponse({
    success: true,
    count: products.length,
    data: products
  });
}

function getProduct(productId) {
  const sheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(SHEET_NAME);

  const data = sheet.getDataRange().getValues();

  const headers = data[0];

  for (let i = 1; i < data.length; i++) {
    if (String(data[i][0]) === String(productId)) {

      const product = {};

      headers.forEach((header, index) => {
        product[header] = data[i][index];
      });

      return jsonResponse({
        success: true,
        data: product
      });
    }
  }

  return jsonResponse({
    success: false,
    message: "Product not found"
  });
}

function addProduct(body) {

  const sheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(SHEET_NAME);

  sheet.appendRow([
    body.product_id || Utilities.getUuid(),
    body.product_name || "",
    body.short_description || "",
    body.sub_category || "",
    body.selling_price || "",
    body.cost_price || "",
    body.mrp || "",
    body.gst || "",
    body.sku || "",
    body.barcode || "",
    body.stock_quantity || "",
    body.low_stock_threshold || "",
    body.featured || false,
    body.hsn_code || "",
    body.country_of_origin || "",
    body.shipping_weight || "",
    body.images || "",
    body.created_at || new Date().toISOString(),
    body.reviews_count || 0,
    body.sold_count || 0
  ]);

  return jsonResponse({
    success: true,
    message: "Product added successfully"
  });
}

function sheetRowsAsObjects(sheet) {
  const data = sheet.getDataRange().getValues();
  if (data.length <= 1) return [];

  const headers = data[0];
  return data.slice(1).map(row => {
    const obj = {};
    headers.forEach((header, index) => {
      obj[header] = row[index];
    });
    return obj;
  });
}

function getOrders() {
  const ordersSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDERS_SHEET_NAME);
  const itemsSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDER_ITEMS_SHEET_NAME);

  const orders = sheetRowsAsObjects(ordersSheet);
  const items = sheetRowsAsObjects(itemsSheet);

  orders.forEach(order => {
    order.items = items.filter(item => String(item.order_id) === String(order.order_id));
  });

  return jsonResponse({
    success: true,
    count: orders.length,
    data: orders
  });
}

function getOrder(orderId) {
  const ordersSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDERS_SHEET_NAME);
  const itemsSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDER_ITEMS_SHEET_NAME);

  const orders = sheetRowsAsObjects(ordersSheet);
  const order = orders.find(o => String(o.order_id) === String(orderId));

  if (!order) {
    return jsonResponse({
      success: false,
      message: "Order not found"
    });
  }

  const items = sheetRowsAsObjects(itemsSheet);
  order.items = items.filter(item => String(item.order_id) === String(orderId));

  return jsonResponse({
    success: true,
    data: order
  });
}

function addOrder(body) {
  const ordersSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDERS_SHEET_NAME);
  const itemsSheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDER_ITEMS_SHEET_NAME);

  const orderId = body.order_id || Utilities.getUuid();
  const items = body.items || [];

  ordersSheet.appendRow([
    orderId,
    body.customer_name || "",
    body.customer_phone || "",
    body.total_amount || 0,
    body.payment_type || "cod",
    body.status || "pending",
    body.created_at || new Date().toISOString()
  ]);

  items.forEach(item => {
    itemsSheet.appendRow([
      orderId,
      item.product_name || "",
      item.quantity || 0,
      item.price || 0
    ]);
  });

  return jsonResponse({
    success: true,
    message: "Order added successfully",
    order_id: orderId
  });
}

function updateOrderStatus(body) {
  const sheet = SpreadsheetApp
    .getActiveSpreadsheet()
    .getSheetByName(ORDERS_SHEET_NAME);

  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const orderIdCol = headers.indexOf("order_id");
  const statusCol = headers.indexOf("status");

  for (let i = 1; i < data.length; i++) {
    if (String(data[i][orderIdCol]) === String(body.order_id)) {
      sheet.getRange(i + 1, statusCol + 1).setValue(body.status);
      return jsonResponse({
        success: true,
        message: "Order status updated"
      });
    }
  }

  return jsonResponse({
    success: false,
    message: "Order not found"
  });
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
