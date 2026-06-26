import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../presentation/cubit/payment_state.dart';

class InvoicePdfGenerator {
  static Future<List<int>> generate(PaymentMethodState state) async {
    // Load Roboto from bundled assets — supports \$ and full Unicode
    final regular =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final medium =
        await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    final bold =
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    final baseFont = pw.Font.ttf(regular);
    final mediumFont = pw.Font.ttf(medium);
    final boldFont = pw.Font.ttf(bold);

    final theme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      italic: baseFont,
      boldItalic: boldFont,
    );

    final pdf = pw.Document(theme: theme);

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')} ${_month(now.month)} ${now.year}';
    final invoiceNo = 'INV-${state.orderId.replaceAll('BG-', '')}';
    final address = state.deliveryAddress.isNotEmpty
        ? '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}'
        : '—';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BINGO Pay',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 22)),
                      pw.SizedBox(height: 4),
                      pw.Text('Tax Invoice',
                          style: pw.TextStyle(
                              font: baseFont,
                              fontSize: 12,
                              color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(invoiceNo,
                          style: pw.TextStyle(
                              font: boldFont, fontSize: 14)),
                      pw.SizedBox(height: 4),
                      pw.Text(dateStr,
                          style: pw.TextStyle(
                              font: baseFont,
                              fontSize: 11,
                              color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.Divider(height: 32, color: PdfColors.grey300),

              // ── Bill To ───────────────────────────────────────────────
              pw.Text('BILLED TO',
                  style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 10,
                      color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              pw.Text(
                  state.deliveryName.isNotEmpty
                      ? state.deliveryName
                      : 'Customer',
                  style: pw.TextStyle(font: boldFont, fontSize: 13)),
              if (state.deliveryPhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(state.deliveryPhone,
                    style: pw.TextStyle(
                        font: baseFont,
                        fontSize: 11,
                        color: PdfColors.grey700)),
              ],
              pw.SizedBox(height: 2),
              pw.Text(address,
                  style: pw.TextStyle(
                      font: baseFont,
                      fontSize: 11,
                      color: PdfColors.grey700)),

              pw.SizedBox(height: 24),

              // ── Order Info ────────────────────────────────────────────
              pw.Text('ORDER DETAILS',
                  style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 10,
                      color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              _infoRow('Order ID', state.orderId, baseFont, boldFont),
              pw.SizedBox(height: 4),
              _infoRow('Payment', state.methodDisplayName, baseFont, boldFont),

              pw.SizedBox(height: 24),

              // ── Line items table ──────────────────────────────────────
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  children: [
                    // Table header
                    pw.Container(
                      color: PdfColors.grey100,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text('ITEM',
                                style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                    color: PdfColors.grey700)),
                          ),
                          pw.Text('QTY',
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 10,
                                  color: PdfColors.grey700)),
                          pw.SizedBox(width: 40),
                          pw.Text('AMOUNT',
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 10,
                                  color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.Divider(height: 1, color: PdfColors.grey300),
                    // Line items
                    if (state.isCartFlow)
                      ...state.cartItems.map((item) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 5,
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(item.name,
                                          style: pw.TextStyle(
                                              font: boldFont, fontSize: 11)),
                                      pw.SizedBox(height: 2),
                                      pw.Text('incl. GST',
                                          style: pw.TextStyle(
                                              font: baseFont,
                                              fontSize: 9,
                                              color: PdfColors.grey600)),
                                    ],
                                  ),
                                ),
                                pw.Text('${item.quantity}',
                                    style: pw.TextStyle(
                                        font: baseFont, fontSize: 11)),
                                pw.SizedBox(width: 40),
                                pw.Text(
                                    '\$${(item.priceValue * item.quantity).toStringAsFixed(0)}',
                                    style: pw.TextStyle(
                                        font: boldFont, fontSize: 11)),
                              ],
                            ),
                          ))
                    else
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 5,
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                      state.productName.isNotEmpty
                                          ? state.productName
                                          : 'Product',
                                      style: pw.TextStyle(
                                          font: boldFont, fontSize: 12)),
                                  pw.SizedBox(height: 2),
                                  pw.Text('Qty 1 • incl. GST',
                                      style: pw.TextStyle(
                                          font: baseFont,
                                          fontSize: 10,
                                          color: PdfColors.grey600)),
                                ],
                              ),
                            ),
                            pw.Text('1',
                                style: pw.TextStyle(
                                    font: baseFont, fontSize: 12)),
                            pw.SizedBox(width: 40),
                            pw.Text(state.formattedTotal,
                                style: pw.TextStyle(
                                    font: boldFont, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // ── Totals ────────────────────────────────────────────────
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.SizedBox(
                  width: 220,
                  child: pw.Column(
                    children: [
                      _totalRow('Subtotal', state.formattedTotal,
                          baseFont, mediumFont),
                      _totalRow('Delivery', 'FREE', baseFont, mediumFont,
                          valueColor: PdfColors.green700),
                      _totalRow('Taxes & fees', 'Incl.', baseFont, mediumFont),
                      pw.Divider(height: 16, color: PdfColors.grey300),
                      _totalRow('Amount Paid', state.formattedTotal,
                          baseFont, boldFont,
                          isBold: true),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // ── Footer ────────────────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping with BINGO Pay  •  support@bingosg.com',
                  style: pw.TextStyle(
                      font: baseFont,
                      fontSize: 10,
                      color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(
      String label, String value, pw.Font base, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Text('$label:',
            style:
                pw.TextStyle(font: base, fontSize: 11, color: PdfColors.grey700)),
        pw.SizedBox(width: 8),
        pw.Text(value,
            style: pw.TextStyle(font: bold, fontSize: 11)),
      ],
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    pw.Font base,
    pw.Font boldFont, {
    bool isBold = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: isBold ? boldFont : base,
                  fontSize: 11,
                  color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(
                  font: isBold ? boldFont : base,
                  fontSize: isBold ? 13 : 11,
                  color: valueColor ?? PdfColors.black)),
        ],
      ),
    );
  }

  static String _month(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
