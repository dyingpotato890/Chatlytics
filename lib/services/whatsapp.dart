import 'dart:io';
import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/models/message.dart';
import 'package:chatlytics/models/streak_info.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class Whatsapp {
  Map<String, List<Message>> messagesByDate = <String, List<Message>>{};

  final RegExp messageLineRegex = RegExp(
    r'^(\d{1,2}\/\d{1,2}\/\d{2,4}),\s+(\d{1,2}:\d{2}(?::\d{2})?\s*(?:[AaPp][Mm])?)\s*[--]\s*([^:]+?):\s*(.*)$',
    caseSensitive: false,
    multiLine: false,
  );

  final RegExp alternativeMessageRegex = RegExp(
    r'^\[(\d{1,2}\/\d{1,2}\/\d{2,4}),\s+(\d{1,2}:\d{2}(?::\d{2})?\s*(?:[AaPp][Mm])?)\]\s+([^:]+?):\s*(.*)$',
    caseSensitive: false,
    multiLine: false,
  );

  // Media detection regex
  final RegExp mediaRegex = RegExp(
    r'<Media omitted>|image omitted|video omitted|audio omitted|sticker omitted|document omitted|GIF omitted',
    caseSensitive: false,
  );

  // System message detection regex
  final RegExp systemMessageRegex = RegExp(
    r"^(Messages and calls are end-to-end encrypted|(?:You|.+) (?:pinned a message|changed the group description|changed the subject|changed this group's icon|added .+|removed .+|left$|joined))$",
    caseSensitive: false,
  );

  // Emoji detection regex
  final RegExp emojiRegex = RegExp(
    r'[#*0-9]\uFE0F?\u20E3|[\xA9\xAE\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9\u21AA\u231A\u231B\u2328\u23CF\u23ED-\u23EF\u23F1\u23F2\u23F8-\u23FA\u24C2\u25AA\u25AB\u25B6\u25C0\u25FB\u25FC\u25FE\u2600-\u2604\u260E\u2611\u2614\u2615\u2618\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u265F\u2660\u2663\u2665\u2666\u2668\u267B\u267E\u267F\u2692\u2694-\u2697\u2699\u269B\u269C\u26A0\u26A7\u26AA\u26B0\u26B1\u26BD\u26BE\u26C4\u26C8\u26CF\u26D1\u26D3\u26E9\u26F0-\u26F5\u26F7\u26F8\u26FA\u2702\u2708\u2709\u270F\u2712\u2714\u2716\u271D\u2721\u2733\u2734\u2744\u2747\u2757\u2763\u27A1\u2934\u2935\u2B05-\u2B07\u2B1B\u2B1C\u2B55\u3030\u303D\u3297\u3299]\uFE0F?|[\u261D\u270C\u270D](?:\uFE0F|\uD83C[\uDFFB-\uDFFF])?|[\u270A\u270B](?:\uD83C[\uDFFB-\uDFFF])?|[\u23E9-\u23EC\u23F0\u23F3\u25FD\u2693\u26A1\u26AB\u26C5\u26CE\u26D4\u26EA\u26FD\u2705\u2728\u274C\u274E\u2753-\u2755\u2795-\u2797\u27B0\u27BF\u2B50]|\u26F9(?:\uFE0F|\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|\u2764\uFE0F?(?:\u200D(?:\uD83D\uDD25|\uD83E\uDE79))?|\uD83C(?:[\uDC04\uDD70\uDD71\uDD7E\uDD7F\uDE02\uDE37\uDF21\uDF24-\uDF2C\uDF36\uDF7D\uDF96\uDF97\uDF99-\uDF9B\uDF9E\uDF9F\uDFCD\uDFCE\uDFD4-\uDFDF\uDFF5\uDFF7]\uFE0F?|[\uDF85\uDFC2\uDFC7](?:\uD83C[\uDFFB-\uDFFF])?|[\uDFC3\uDFC4\uDFCA](?:\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|[\uDFCB\uDFCC](?:\uFE0F|\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|[\uDCCF\uDD8E\uDD91-\uDD9A\uDE01\uDE1A\uDE2F\uDE32-\uDE36\uDE38-\uDE3A\uDE50\uDE51\uDF00-\uDF20\uDF2D-\uDF35\uDF37-\uDF7C\uDF7E-\uDF84\uDF86-\uDF93\uDFA0-\uDFC1\uDFC5\uDFC6\uDFC8\uDFC9\uDFCF-\uDFD3\uDFE0-\uDFF0\uDFF8-\uDFFF]|\uDDE6\uD83C[\uDDE8-\uDDEC\uDDEE\uDDF1\uDDF2\uDDF4\uDDF6-\uDDFA\uDDFC\uDDFD\uDDFF]|\uDDE7\uD83C[\uDDE6\uDDE7\uDDE9-\uDDEF\uDDF1-\uDDF4\uDDF6-\uDDF9\uDDFB\uDDFC\uDDFE\uDDFF]|\uDDE8\uD83C[\uDDE6\uDDE8\uDDE9\uDDEB-\uDDEE\uDDF0-\uDDF5\uDDF7\uDDFA-\uDDFF]|\uDDE9\uD83C[\uDDEA\uDDEC\uDDEF\uDDF0\uDDF2\uDDF4\uDDFF]|\uDDEA\uD83C[\uDDE6\uDDE8\uDDEA\uDDEC\uDDED\uDDF7-\uDDFA]|\uDDEB\uD83C[\uDDEE-\uDDF0\uDDF2\uDDF4\uDDF7]|\uDDEC\uD83C[\uDDE6\uDDE7\uDDE9-\uDDEE\uDDF1-\uDDF3\uDDF5-\uDDFA\uDDFC\uDDFE]|\uDDED\uD83C[\uDDF0\uDDF2\uDDF3\uDDF7\uDDF9\uDDFA]|\uDDEE\uD83C[\uDDE8-\uDDEA\uDDF1-\uDDF4\uDDF6-\uDDF9]|\uDDEF\uD83C[\uDDEA\uDDF2\uDDF4\uDDF5]|\uDDF0\uD83C[\uDDEA\uDDEC-\uDDEE\uDDF2\uDDF3\uDDF5\uDDF7\uDDFC\uDDFE\uDDFF]|\uDDF1\uD83C[\uDDE6-\uDDE8\uDDEE\uDDF0\uDDF7-\uDDFB\uDDFE]|\uDDF2\uD83C[\uDDE6\uDDE8-\uDDED\uDDF0-\uDDFF]|\uDDF3\uD83C[\uDDE6\uDDE8\uDDEA-\uDDEC\uDDEE\uDDF1\uDDF4\uDDF5\uDDF7\uDDFA\uDDFF]|\uDDF4\uD83C\uDDF2|\uDDF5\uD83C[\uDDE6\uDDEA-\uDDED\uDDF0-\uDDF3\uDDF7-\uDDF9\uDDFC\uDDFE]|\uDDF6\uD83C\uDDE6|\uDDF7\uD83C[\uDDEA\uDDF4\uDDF8\uDDFA\uDDFC]|\uDDF8\uD83C[\uDDE6-\uDDEA\uDDEC-\uDDF4\uDDF7-\uDDF9\uDDFB\uDDFD-\uDDFF]|\uDDF9\uD83C[\uDDE6\uDDE8\uDDE9\uDDEB-\uDDED\uDDEF-\uDDF4\uDDF7\uDDF9\uDDFB\uDDFC\uDDFF]|\uDDFA\uD83C[\uDDE6\uDDEC\uDDF2\uDDF3\uDDF8\uDDFE\uDDFF]|\uDDFB\uD83C[\uDDE6\uDDE8\uDDEA\uDDEC\uDDEE\uDDF3\uDDFA]|\uDDFC\uD83C[\uDDEB\uDDF8]|\uDDFD\uD83C\uDDF0|\uDDFE\uD83C[\uDDEA\uDDF9]|\uDDFF\uD83C[\uDDE6\uDDF2\uDDFC]|\uDFF3\uFE0F?(?:\u200D(?:\u26A7\uFE0F?|\uD83C\uDF08))?|\uDFF4(?:\u200D\u2620\uFE0F?|\uDB40\uDC67\uDB40\uDC62\uDB40(?:\uDC65\uDB40\uDC6E\uDB40\uDC67|\uDC73\uDB40\uDC63\uDB40\uDC74|\uDC77\uDB40\uDC6C\uDB40\uDC73)\uDB40\uDC7F)?)|\uD83D(?:[\uDC08\uDC26](?:\u200D\u2B1B)?|[\uDC3F\uDCFD\uDD49\uDD4A\uDD6F\uDD70\uDD73\uDD76-\uDD79\uDD87\uDD8A-\uDD8D\uDDA5\uDDA8\uDDB1\uDDB2\uDDBC\uDDC2-\uDDC4\uDDD1-\uDDD3\uDDDC-\uDDDE\uDDE1\uDDE3\uDDE8\uDDEF\uDDF3\uDDFA\uDECB\uDECD-\uDECF\uDEE0-\uDEE5\uDEE9\uDEF0\uDEF3]\uFE0F?|[\uDC42\uDC43\uDC46-\uDC50\uDC66\uDC67\uDC6B-\uDC6D\uDC72\uDC74-\uDC76\uDC78\uDC7C\uDC83\uDC85\uDC8F\uDC91\uDCAA\uDD7A\uDD95\uDD96\uDE4C\uDE4F\uDEC0\uDECC](?:\uD83C[\uDFFB-\uDFFF])?|[\uDC6E\uDC70\uDC71\uDC73\uDC77\uDC81\uDC82\uDC86\uDC87\uDE45-\uDE47\uDE4B\uDE4D\uDE4E\uDEA3\uDEB4-\uDEB6](?:\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|[\uDD74\uDD90](?:\uFE0F|\uD83C[\uDFFB-\uDFFF])?|[\uDC00-\uDC07\uDC09-\uDC14\uDC16-\uDC25\uDC27-\uDC3A\uDC3C-\uDC3E\uDC40\uDC44\uDC45\uDC51-\uDC65\uDC6A\uDC79-\uDC7B\uDC7D-\uDC80\uDC84\uDC88-\uDC8E\uDC90\uDC92-\uDCA9\uDCAB-\uDCFC\uDCFF-\uDD3D\uDD4B-\uDD4E\uDD50-\uDD67\uDDA4\uDDFB-\uDE2D\uDE2F-\uDE34\uDE37-\uDE44\uDE48-\uDE4A\uDE80-\uDEA2\uDEA4-\uDEB3\uDEB7-\uDEBF\uDEC1-\uDEC5\uDED0-\uDED2\uDED5-\uDED7\uDEDC-\uDEDF\uDEEB\uDEEC\uDEF4-\uDEFC\uDFE0-\uDFEB\uDFF0]|\uDC15(?:\u200D\uD83E\uDDBA)?|\uDC3B(?:\u200D\u2744\uFE0F?)?|\uDC41\uFE0F?(?:\u200D\uD83D\uDDE8\uFE0F?)?|\uDC68(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D(?:[\uDC68\uDC69]\u200D\uD83D(?:\uDC66(?:\u200D\uD83D\uDC66)?|\uDC67(?:\u200D\uD83D[\uDC66\uDC67])?)|[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uDC66(?:\u200D\uD83D\uDC66)?|\uDC67(?:\u200D\uD83D[\uDC66\uDC67])?)|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C(?:\uDFFB(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D\uDC68\uD83C[\uDFFC-\uDFFF])))?|\uDFFC(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D\uDC68\uD83C[\uDFFB\uDFFD-\uDFFF])))?|\uDFFD(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D\uDC68\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF])))?|\uDFFE(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D\uDC68\uD83C[\uDFFB-\uDFFD\uDFFF])))?|\uDFFF(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?\uDC68\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D\uDC68\uD83C[\uDFFB-\uDFFE])))?))?|\uDC69(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:\uDC8B\u200D\uD83D)?[\uDC68\uDC69]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D(?:[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uDC66(?:\u200D\uD83D\uDC66)?|\uDC67(?:\u200D\uD83D[\uDC66\uDC67])?|\uDC69\u200D\uD83D(?:\uDC66(?:\u200D\uD83D\uDC66)?|\uDC67(?:\u200D\uD83D[\uDC66\uDC67])?))|\uD83E[\uDDAF-\uDDB3\uDDBC\uDDBD])|\uD83C(?:\uDFFB(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:[\uDC68\uDC69]|\uDC8B\u200D\uD83D[\uDC68\uDC69])\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D[\uDC68\uDC69]\uD83C[\uDFFC-\uDFFF])))?|\uDFFC(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:[\uDC68\uDC69]|\uDC8B\u200D\uD83D[\uDC68\uDC69])\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D[\uDC68\uDC69]\uD83C[\uDFFB\uDFFD-\uDFFF])))?|\uDFFD(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:[\uDC68\uDC69]|\uDC8B\u200D\uD83D[\uDC68\uDC69])\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D[\uDC68\uDC69]\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF])))?|\uDFFE(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:[\uDC68\uDC69]|\uDC8B\u200D\uD83D[\uDC68\uDC69])\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D[\uDC68\uDC69]\uD83C[\uDFFB-\uDFFD\uDFFF])))?|\uDFFF(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D\uD83D(?:[\uDC68\uDC69]|\uDC8B\u200D\uD83D[\uDC68\uDC69])\uD83C[\uDFFB-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83D[\uDC68\uDC69]\uD83C[\uDFFB-\uDFFE])))?))?|\uDC6F(?:\u200D[\u2640\u2642]\uFE0F?)?|\uDD75(?:\uFE0F|\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|\uDE2E(?:\u200D\uD83D\uDCA8)?|\uDE35(?:\u200D\uD83D\uDCAB)?|\uDE36(?:\u200D\uD83C\uDF2B\uFE0F?)?)|\uD83E(?:[\uDD0C\uDD0F\uDD18-\uDD1F\uDD30-\uDD34\uDD36\uDD77\uDDB5\uDDB6\uDDBB\uDDD2\uDDD3\uDDD5\uDEC3-\uDEC5\uDEF0\uDEF2-\uDEF8](?:\uD83C[\uDFFB-\uDFFF])?|[\uDD26\uDD35\uDD37-\uDD39\uDD3D\uDD3E\uDDB8\uDDB9\uDDCD-\uDDCF\uDDD4\uDDD6-\uDDDD](?:\uD83C[\uDFFB-\uDFFF])?(?:\u200D[\u2640\u2642]\uFE0F?)?|[\uDDDE\uDDDF](?:\u200D[\u2640\u2642]\uFE0F?)?|[\uDD0D\uDD0E\uDD10-\uDD17\uDD20-\uDD25\uDD27-\uDD2F\uDD3A\uDD3F-\uDD45\uDD47-\uDD76\uDD78-\uDDB4\uDDB7\uDDBA\uDDBC-\uDDCC\uDDD0\uDDE0-\uDDFF\uDE70-\uDE7C\uDE80-\uDE88\uDE90-\uDEBD\uDEBF-\uDEC2\uDECE-\uDEDB\uDEE0-\uDEE8]|\uDD3C(?:\u200D[\u2640\u2642]\uFE0F?|\uD83C[\uDFFB-\uDFFF])?|\uDDD1(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1))|\uD83C(?:\uDFFB(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D(?:\uD83D\uDC8B\u200D)?\uD83E\uDDD1\uD83C[\uDFFC-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1\uD83C[\uDFFB-\uDFFF])))?|\uDFFC(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D(?:\uD83D\uDC8B\u200D)?\uD83E\uDDD1\uD83C[\uDFFB\uDFFD-\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1\uD83C[\uDFFB-\uDFFF])))?|\uDFFD(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D(?:\uD83D\uDC8B\u200D)?\uD83E\uDDD1\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1\uD83C[\uDFFB-\uDFFF])))?|\uDFFE(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D(?:\uD83D\uDC8B\u200D)?\uD83E\uDDD1\uD83C[\uDFFB-\uDFFD\uDFFF]|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1\uD83C[\uDFFB-\uDFFF])))?|\uDFFF(?:\u200D(?:[\u2695\u2696\u2708]\uFE0F?|\u2764\uFE0F?\u200D(?:\uD83D\uDC8B\u200D)?\uD83E\uDDD1\uD83C[\uDFFB-\uDFFE]|\uD83C[\uDF3E\uDF73\uDF7C\uDF84\uDF93\uDFA4\uDFA8\uDFEB\uDFED]|\uD83D[\uDCBB\uDCBC\uDD27\uDD2C\uDE80\uDE92]|\uD83E(?:[\uDDAF-\uDDB3\uDDBC\uDDBD]|\uDD1D\u200D\uD83E\uDDD1\uD83C[\uDFFB-\uDFFF])))?))?|\uDEF1(?:\uD83C(?:\uDFFB(?:\u200D\uD83E\uDEF2\uD83C[\uDFFC-\uDFFF])?|\uDFFC(?:\u200D\uD83E\uDEF2\uD83C[\uDFFB\uDFFD-\uDFFF])?|\uDFFD(?:\u200D\uD83E\uDEF2\uD83C[\uDFFB\uDFFC\uDFFE\uDFFF])?|\uDFFE(?:\u200D\uD83E\uDEF2\uD83C[\uDFFB-\uDFFD\uDFFF])?|\uDFFF(?:\u200D\uD83E\uDEF2\uD83C[\uDFFB-\uDFFE])?))?)',
  );

  bool isSystemMessage(String sender, String? message) {
    // Check for null messages
    if (message == null) {
      return true;
    }

    // Check if the sender contains system notification markers
    if (sender.contains("pinned a message")) {
      return true;
    }

    // Standard system message
    if (sender ==
            "Messages and calls are end-to-end encrypted. Only people in this chat can read, listen to, or share them. Learn more." ||
        sender == "You pinned a message") {
      return true;
    }

    // Check specific system message
    if (message == "left" ||
        message == "joined" ||
        message == "You pinned a message" ||
        message.startsWith("changed the subject") ||
        message.startsWith("changed this group's icon") ||
        sender.startsWith("added ") ||
        sender.startsWith("removed ") ||
        message == "Messages and calls are end-to-end encrypted") {
      return true;
    }

    return false;
  }

  String _extractHour(String time) {
    // Handle different time formats
    if (time.toLowerCase().contains('am') ||
        time.toLowerCase().contains('pm')) {
      // 12-hour format
      String hourPart = time.split(':')[0].trim();
      String ampm = time.toLowerCase().contains('pm') ? 'PM' : 'AM';
      return '$hourPart $ampm';
    } else {
      // 24-hour format
      return time.split(':')[0];
    }
  }

  DateTime _parseDate(String date) {
    List<String> parts = date.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    // Handle both YY and YYYY formats
    if (year < 100) {
      // YY format - assume 20YY for years less than 100
      year += 2000;
    }

    return DateTime(year, month, day);
  }

  String _getDayOfWeek(DateTime date) {
    const List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdays[date.weekday - 1];
  }

  Map<String, dynamic> _calculateDetailedStreaks(List<DateTime> dates) {
    if (dates.isEmpty) {
      return {
        'highestDayStreak': 0,
        'longestStreak': null,
        'currentStreak': null,
        'allStreaks': <StreakInfo>[],
      };
    }

    // Sort dates and remove duplicates (only keep date part, ignore time)
    Set<DateTime> uniqueDatesSet =
        dates.map((date) => DateTime(date.year, date.month, date.day)).toSet();
    List<DateTime> sortedDates = uniqueDatesSet.toList()..sort();

    List<StreakInfo> allStreaks = [];
    int maxStreakLength = 1;
    int currentStreakLength = 1;
    DateTime currentStreakStart = sortedDates[0];
    DateTime currentStreakEnd = sortedDates[0];
    StreakInfo? longestStreak;

    for (int i = 1; i < sortedDates.length; i++) {
      DateTime prevDate = sortedDates[i - 1];
      DateTime currentDate = sortedDates[i];

      // Check if dates are consecutive
      if (currentDate.difference(prevDate).inDays == 1) {
        currentStreakLength++;
        currentStreakEnd = currentDate;
      } else {
        // End of current streak, record it
        StreakInfo streak = StreakInfo(
          length: currentStreakLength,
          startDate: currentStreakStart,
          endDate: currentStreakEnd,
        );
        allStreaks.add(streak);

        // Check if this is the longest streak so far
        if (currentStreakLength > maxStreakLength) {
          maxStreakLength = currentStreakLength;
          longestStreak = streak;
        }

        // Start new streak
        currentStreakLength = 1;
        currentStreakStart = currentDate;
        currentStreakEnd = currentDate;
      }
    }

    // Don't forget to add the last streak
    StreakInfo lastStreak = StreakInfo(
      length: currentStreakLength,
      startDate: currentStreakStart,
      endDate: currentStreakEnd,
    );
    allStreaks.add(lastStreak);

    // Check if the last streak is the longest
    if (currentStreakLength > maxStreakLength) {
      maxStreakLength = currentStreakLength;
      longestStreak = lastStreak;
    }

    // Determine current streak (if the last date is recent)
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    StreakInfo? currentStreak;
    DateTime lastActiveDate = sortedDates.last;

    // Current streak is active if last message was today or yesterday
    if (lastActiveDate == today || lastActiveDate == yesterday) {
      currentStreak = lastStreak;
    }

    return {
      'highestDayStreak': maxStreakLength,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'allStreaks': allStreaks,
    };
  }

  String getFormattedMessagesForDay(String date) {
    if (!messagesByDate.containsKey(date)) return '';

    return messagesByDate[date]!
        .map((msg) => '${msg.time} - ${msg.sender}: ${msg.message}')
        .join('\n');
  }

  void processMessage(
    String date,
    String time,
    String sender,
    String? message,
    Data messageData,
    Set<String> uniqueDays,
    Set<String> uniqueParticipants,
    List<DateTime> messageDates,
  ) {
    bool isSystem = isSystemMessage(sender, message);

    if (!isSystem) {
      // First Message
      if (messageData.messageCount == 0) {
        messageData.firstMessage = Message(
          date: date,
          time: time,
          sender: sender,
          message: message ?? '',
        );
      }

      // Last Message
      messageData.lastMessage = Message(
        date: date,
        time: time,
        sender: sender,
        message: message ?? '',
      );

      messageData.messageCount++;

      uniqueParticipants.add(sender);
      messageData.participants = uniqueParticipants.length;

      // Track user message counts
      if (!messageData.userMessagesCount.containsKey(sender)) {
        messageData.userMessagesCount[sender] = 1;
      } else {
        messageData.userMessagesCount[sender] =
            messageData.userMessagesCount[sender]! + 1;
      }

      // Process date and time metrics
      String dayKey = date;
      String monthKey = date.split('/')[1];
      String hourKey = _extractHour(time);
      String yearKey = date.split('/')[2];
      DateTime parsedDate = _parseDate(date);
      messageDates.add(parsedDate);
      String weekDay = _getDayOfWeek(parsedDate);

      // Track unique days
      uniqueDays.add(dayKey);
      messageData.activeDays = uniqueDays.length;

      // Most talked days
      if (!messageData.mostTalkedDays.containsKey(dayKey)) {
        messageData.mostTalkedDays[dayKey] = 1;
      } else {
        messageData.mostTalkedDays[dayKey] =
            messageData.mostTalkedDays[dayKey]! + 1;
      }

      // Most talked hours
      if (!messageData.mostTalkedHours.containsKey(hourKey)) {
        messageData.mostTalkedHours[hourKey] = 1;
      } else {
        messageData.mostTalkedHours[hourKey] =
            messageData.mostTalkedHours[hourKey]! + 1;
      }

      // Chat by Month
      if (!messageData.monthCount.containsKey(monthKey)) {
        messageData.monthCount[monthKey] = 1;
      } else {
        messageData.monthCount[monthKey] =
            messageData.monthCount[monthKey]! + 1;
      }

      // Chat by Year
      if (!messageData.yearCount.containsKey(yearKey)) {
        messageData.yearCount[yearKey] = 1;
      } else {
        messageData.yearCount[yearKey] = messageData.yearCount[yearKey]! + 1;
      }

      // Chat by Week Day
      messageData.weekCount[weekDay] = messageData.weekCount[weekDay]! + 1;

      // Group messages by date for AI analysis
      if (!messageData.messagesByDate.containsKey(dayKey.trim())) {
        messageData.messagesByDate[dayKey.trim()] = <Message>[];
      }
      messageData.messagesByDate[dayKey.trim()]!.add(
        Message(date: date, time: time, sender: sender, message: message ?? ''),
      );

      // Process message content if available
      if (message != null && message.isNotEmpty) {
        // Check for media
        if (mediaRegex.hasMatch(message)) {
          messageData.mediaShared++;
        } else {
          // Extract words
          List<String> words =
              RegExp(r'\b\w+\b')
                  .allMatches(message)
                  .map((match) => match.group(0)!.toLowerCase())
                  .toList();

          messageData.wordCount += words.length;

          for (String word in words) {
            // Filter short words
            if (word.length > 3) {
              messageData.mostUsedWords[word] =
                  (messageData.mostUsedWords[word] ?? 0) + 1;
            }
          }

          // Process emojies
          final emojis = emojiRegex.allMatches(message);
          for (Match emoji in emojis) {
            String emojiChar = emoji.group(0)!;
            if (!messageData.mostUsedEmojies.containsKey(emojiChar)) {
              messageData.mostUsedEmojies[emojiChar] = 1;
            } else {
              messageData.mostUsedEmojies[emojiChar] =
                  messageData.mostUsedEmojies[emojiChar]! + 1;
            }
          }
        }
      }
    }
  }

  Future<List<String>> extractZipAndReadTxt(String zipPath) async {
    try {
      // Get a directory to extract files
      final outputDir = await getTemporaryDirectory();
      final destinationDir = Directory(
        '${outputDir.path}/extracted_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Clean up any existing extraction directories first
      await _cleanupOldExtractions(outputDir);

      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      // Extract the zip file
      final zipFile = File(zipPath);
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
      );

      // Find the .txt file
      final txtFile = destinationDir
          .listSync(recursive: true)
          .whereType<File>()
          .firstWhere((f) => f.path.endsWith('.txt'), orElse: () => File(''));

      if (txtFile.path.isEmpty || !(await txtFile.exists())) {
        return ["No .txt file found in archive."];
      }

      // Read line by line
      final lines = await txtFile.readAsLines();

      // Clean up the extraction directory after reading
      try {
        await destinationDir.delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }

      return lines;
    } catch (e) {
      return [e.toString()];
    }
  }

  Future<void> _cleanupOldExtractions(Directory tempDir) async {
    try {
      final extractedDirs = tempDir.listSync().whereType<Directory>().where(
        (dir) => dir.path.contains('extracted_'),
      );

      for (final dir in extractedDirs) {
        try {
          await dir.delete(recursive: true);
        } catch (e) {
          // Ignore individual cleanup errors
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  Future<Data> getAttributes(String? filePath) async {
    try {
      // Create a fresh Data object for each analysis
      Data messageData = _createFreshDataObject();

      final Set<String> uniqueDays = {};
      final Set<String> uniqueParticipants = {};
      final List<DateTime> messageDates = [];

      filePath = filePath ?? "";

      if (filePath.isNotEmpty) {
        final List<String> content = await extractZipAndReadTxt(filePath);

        // Process the content with fresh variables
        String? currentDate, currentTime, currentSender;
        StringBuffer currentMessage = StringBuffer();
        bool inMultiLineMessage = false;

        for (int i = 0; i < content.length; i++) {
          String line = content[i];

          // Try primary regex first
          RegExpMatch? match = messageLineRegex.firstMatch(line);

          // If no match, try alternative regex
          match ??= alternativeMessageRegex.firstMatch(line);

          if (match != null) {
            // Process previous message if exists
            if (inMultiLineMessage &&
                currentDate != null &&
                currentSender != null) {
              processMessage(
                currentDate,
                currentTime!,
                currentSender,
                currentMessage.toString().trim(),
                messageData,
                uniqueDays,
                uniqueParticipants,
                messageDates,
              );
            }

            // Start new message
            currentDate = match.group(1);
            currentTime = match.group(2);
            currentSender = match.group(3)?.trim();
            currentMessage.clear();
            currentMessage.write(match.group(4) ?? "");
            inMultiLineMessage = true;
          } else if (inMultiLineMessage) {
            // This is a continuation of the previous message
            if (currentMessage.isNotEmpty) {
              currentMessage.write("\n");
            }
            currentMessage.write(line);
          }
        }

        // Process the last message if there was one
        if (inMultiLineMessage &&
            currentDate != null &&
            currentSender != null) {
          processMessage(
            currentDate,
            currentTime!,
            currentSender,
            currentMessage.toString().trim(),
            messageData,
            uniqueDays,
            uniqueParticipants,
            messageDates,
          );
        }

        // Sort the maps
        messageData.mostUsedWords = _sortMapByValueDesc(
          messageData.mostUsedWords,
        );
        messageData.mostUsedEmojies = _sortMapByValueDesc(
          messageData.mostUsedEmojies,
        );
        messageData.mostTalkedDays = _sortMapByValueDesc(
          messageData.mostTalkedDays,
        );
        messageData.mostTalkedHours = _sortMapByValueDesc(
          messageData.mostTalkedHours,
        );

        Map<String, dynamic> streakData = _calculateDetailedStreaks(
          messageDates,
        );
        messageData.highestDayStreak = streakData['highestDayStreak'];
        messageData.longestStreak = streakData['longestStreak'];
        messageData.allStreaks = streakData['allStreaks'];
      }

      return messageData;
    } catch (e) {
      // Return a fresh empty Data object on error
      return _createFreshDataObject();
    }
  }

  Data _createFreshDataObject() {
    return Data(
      messageCount: 0,
      wordCount: 0,
      userMessagesCount: <String, int>{},
      mediaShared: 0,
      activeDays: 0,
      participants: 0,
      mostUsedWords: <String, int>{},
      mostUsedEmojies: <String, int>{},
      mostTalkedDays: <String, int>{},
      mostTalkedHours: <String, int>{},
      monthCount: <String, int>{},
      weekCount: <String, int>{
        "Sunday": 0,
        "Monday": 0,
        "Tuesday": 0,
        "Wednesday": 0,
        "Thursday": 0,
        "Friday": 0,
        "Saturday": 0,
      },
      yearCount: <String, int>{},
      firstMessage: Message(date: '', time: '', sender: '', message: ''),
      lastMessage: Message(date: '', time: '', sender: '', message: ''),
      highestDayStreak: 0,
      longestStreak: null,
      allStreaks: <StreakInfo>[],
      messagesByDate: <String, List<Message>>{},
    );
  }

  // Sort maps by value in descending order
  Map<String, int> _sortMapByValueDesc(Map<String, int> map) {
    List<MapEntry<String, int>> entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> sortedMap = {};
    for (var entry in entries) {
      sortedMap[entry.key] = entry.value;
    }

    return sortedMap;
  }
}
