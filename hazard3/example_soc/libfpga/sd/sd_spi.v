module sd_controller
  (output cs,
   output mosi,
   input  miso,
   output sclk,
   input  card_present,
   input  card_write_prot,
   input  rd,
   input  rd_multiple,
   output [7:0] dout,
   output dout_avail,
   input  dout_taken,
   input  wr,
   input  wr_multiple,
   input  [7:0] din,
   input  din_valid,
   output din_taken,
   input  [31:0] addr,
   input  [7:0] erase_count,
   output sd_error,
   output sd_busy,
   output [2:0] sd_error_code,
   input  reset,
   input  clk,
   output [1:0] sd_type,
   output [7:0] sd_fsm);
  reg [5:0] state;
  reg [5:0] new_state;
  reg [5:0] return_state;
  reg [5:0] new_return_state;
  reg [5:0] sr_return_state;
  reg [5:0] new_sr_return_state;
  reg set_return_state;
  reg set_sr_return_state;
  reg new_sclk;
  reg scs;
  reg new_cs;
  reg set_davail;
  reg sdavail;
  reg transfer_data_out;
  reg new_transfer_data_out;
  reg [1:0] card_type;
  reg [1:0] new_card_type;
  reg error;
  reg new_error;
  reg [2:0] error_code;
  reg [2:0] new_error_code;
  reg new_busy;
  reg sdin_taken;
  reg new_din_taken;
  reg [39:0] cmd_out;
  reg [39:0] new_cmd_out;
  reg set_cmd_out;
  wire [7:0] data_in;
  wire [7:0] new_data_in;
  wire [6:0] new_crc7;
  wire [6:0] crc7;
  wire [15:0] new_in_crc16;
  wire [15:0] in_crc16;
  wire [15:0] new_out_crc16;
  wire [15:0] out_crc16;
  wire [7:0] new_crclow;
  wire [7:0] crclow;
  reg [7:0] data_out;
  reg [7:0] new_data_out;
  wire [31:0] address;
  wire [31:0] new_address;
  wire [7:0] wr_erase_count;
  wire [7:0] new_wr_erase_count;
  reg set_address;
  reg [9:0] byte_counter;
  reg [9:0] new_byte_counter;
  reg set_byte_counter;
  reg [7:0] bit_counter;
  reg [7:0] new_bit_counter;
  reg slow_clock;
  reg new_slow_clock;
  reg [6:0] clock_divider;
  reg [6:0] new_clock_divider;
  reg multiple;
  reg new_multiple;
  reg skipfirstr1byte;
  reg new_skipfirstr1byte;
  reg din_latch;
  reg last_din_valid;
  wire [5:0] n59;
  wire [5:0] n60;
  wire [39:0] n61;
  wire [31:0] n62;
  wire [9:0] n63;
  wire n64;
  wire n65;
  wire n67;
  wire n69;
  wire [7:0] n70;
  wire n72;
  wire n74;
  wire n75;
  wire n76;
  wire n77;
  wire n78;
  wire n79;
  wire n80;
  wire n81;
  wire n82;
  wire n84;
  wire n86;
  wire n88;
  wire n90;
  wire n92;
  wire n94;
  wire n96;
  wire n98;
  wire n100;
  wire n102;
  wire n104;
  wire n106;
  wire [7:0] n108;
  wire n110;
  wire n112;
  wire n114;
  wire n116;
  wire [2:0] n118;
  wire [1:0] n120;
  wire [5:0] n122;
  wire [5:0] n124;
  wire [5:0] n126;
  wire n128;
  wire n130;
  wire n132;
  wire [1:0] n134;
  wire n136;
  wire [2:0] n138;
  wire n140;
  wire [39:0] n142;
  wire [7:0] n144;
  wire [6:0] n146;
  wire [15:0] n148;
  wire [15:0] n150;
  wire [7:0] n152;
  wire [7:0] n154;
  wire [31:0] n156;
  wire [7:0] n158;
  wire [9:0] n160;
  wire [7:0] n162;
  wire n164;
  wire [6:0] n166;
  wire n168;
  wire n170;
  wire n171;
  wire n172;
  wire n215;
  wire [5:0] n217;
  wire n219;
  wire [31:0] n220;
  wire n222;
  wire [5:0] n225;
  wire n227;
  wire n229;
  wire n231;
  wire [5:0] n234;
  wire [5:0] n237;
  wire n240;
  wire [1:0] n242;
  wire n244;
  wire [2:0] n246;
  wire [39:0] n249;
  wire n252;
  wire n254;
  wire n255;
  wire [5:0] n258;
  wire [5:0] n261;
  wire n264;
  wire [1:0] n267;
  wire n269;
  wire n271;
  wire n273;
  wire n280;
  wire n282;
  wire [5:0] n285;
  wire n287;
  wire n289;
  wire n291;
  wire [39:0] n294;
  wire n296;
  wire n297;
  wire n298;
  wire n300;
  wire [5:0] n303;
  wire [5:0] n305;
  wire n307;
  wire n309;
  wire n310;
  wire [5:0] n313;
  wire [5:0] n316;
  wire n319;
  wire [1:0] n321;
  wire n323;
  wire [2:0] n325;
  wire n327;
  wire n328;
  wire [1:0] n330;
  wire n332;
  wire n334;
  wire n336;
  wire n338;
  wire n340;
  wire [5:0] n342;
  wire n343;
  wire n344;
  wire n345;
  wire n346;
  wire n347;
  wire n348;
  wire n349;
  wire [5:0] n351;
  wire n353;
  wire [2:0] n355;
  wire n357;
  wire n359;
  wire n360;
  wire n362;
  wire n363;
  wire n364;
  wire [7:0] n366;
  wire n369;
  wire [5:0] n371;
  wire n373;
  wire n376;
  wire [2:0] n379;
  wire [31:0] n381;
  wire [7:0] n382;
  wire n385;
  wire n386;
  wire n387;
  wire n389;
  wire n390;
  wire [2:0] n391;
  wire n394;
  wire [31:0] n396;
  wire n397;
  wire n399;
  wire n400;
  wire [5:0] n402;
  wire n404;
  wire n406;
  wire [2:0] n408;
  wire n410;
  wire [31:0] n411;
  wire [7:0] n412;
  wire n414;
  wire n416;
  wire [5:0] n418;
  wire n420;
  wire n422;
  wire [2:0] n424;
  wire n426;
  wire [31:0] n427;
  wire [7:0] n428;
  wire n430;
  wire n432;
  wire [5:0] n434;
  wire n435;
  wire n436;
  wire [2:0] n437;
  wire n439;
  wire [31:0] n441;
  wire [7:0] n442;
  wire n444;
  wire n445;
  wire [5:0] n447;
  wire n448;
  wire n449;
  wire [2:0] n450;
  wire n452;
  wire [31:0] n454;
  wire [7:0] n455;
  wire n457;
  wire n458;
  wire n460;
  wire n462;
  wire [39:0] n464;
  wire [22:0] n465;
  wire [30:0] n467;
  wire [39:0] n469;
  wire [39:0] n470;
  wire n472;
  wire n474;
  wire [39:0] n476;
  wire [22:0] n477;
  wire [30:0] n479;
  wire [39:0] n481;
  wire [39:0] n482;
  wire n484;
  wire n486;
  wire [5:0] n489;
  wire [5:0] n492;
  wire n495;
  wire n497;
  wire [2:0] n499;
  wire n501;
  wire n502;
  wire n503;
  wire n504;
  wire n506;
  wire [3:0] n507;
  wire n509;
  wire [5:0] n512;
  wire n514;
  wire [2:0] n516;
  wire [5:0] n518;
  wire [5:0] n521;
  wire n524;
  wire n526;
  wire n527;
  wire [2:0] n528;
  wire [9:0] n530;
  wire n533;
  wire [5:0] n535;
  wire [5:0] n537;
  wire n539;
  wire n540;
  wire n541;
  wire [2:0] n542;
  wire [9:0] n543;
  wire n545;
  wire n547;
  wire n548;
  wire n549;
  wire n550;
  wire [31:0] n551;
  wire n553;
  wire [5:0] n556;
  wire n559;
  wire n561;
  wire [5:0] n564;
  wire [5:0] n566;
  wire n568;
  wire n569;
  wire n571;
  wire [31:0] n572;
  wire n574;
  wire [5:0] n577;
  wire [5:0] n580;
  wire [5:0] n582;
  wire n585;
  wire n587;
  wire n589;
  wire n591;
  wire n592;
  wire [5:0] n595;
  wire [5:0] n598;
  wire n601;
  wire [5:0] n603;
  wire [5:0] n605;
  wire n607;
  wire n609;
  wire [2:0] n611;
  wire n613;
  wire n614;
  wire n615;
  wire n616;
  wire [5:0] n619;
  wire [5:0] n620;
  wire n622;
  wire n624;
  wire n626;
  wire n627;
  wire [5:0] n629;
  wire [5:0] n631;
  wire n633;
  wire n635;
  wire [39:0] n637;
  wire [5:0] n640;
  wire n642;
  wire n644;
  wire [39:0] n646;
  wire [22:0] n647;
  wire [30:0] n649;
  wire [39:0] n651;
  wire [39:0] n652;
  wire n654;
  wire n656;
  wire [39:0] n658;
  wire [22:0] n659;
  wire [30:0] n661;
  wire [39:0] n663;
  wire [39:0] n664;
  wire n666;
  wire n668;
  wire [5:0] n671;
  wire n673;
  wire [2:0] n675;
  wire n677;
  wire [7:0] n680;
  wire n682;
  wire n684;
  wire [31:0] n685;
  wire n687;
  wire [7:0] n688;
  wire [7:0] n689;
  wire n690;
  wire n691;
  wire n692;
  wire [5:0] n694;
  wire [5:0] n697;
  wire n700;
  wire n702;
  wire [7:0] n703;
  wire [5:0] n705;
  wire [5:0] n707;
  wire n709;
  wire n710;
  wire [7:0] n711;
  wire [5:0] n713;
  wire [5:0] n715;
  wire n717;
  wire n718;
  wire [7:0] n719;
  wire [7:0] n720;
  wire n722;
  wire n724;
  wire n726;
  wire n727;
  wire n729;
  wire n730;
  wire n732;
  wire n733;
  wire [31:0] n734;
  wire n736;
  wire [31:0] n737;
  wire [31:0] n739;
  wire [9:0] n740;
  wire [5:0] n743;
  wire n745;
  wire [2:0] n747;
  wire [9:0] n748;
  wire n751;
  wire [2:0] n752;
  wire n754;
  wire [5:0] n757;
  wire [5:0] n760;
  wire n763;
  wire n765;
  wire [2:0] n767;
  wire [39:0] n770;
  wire n773;
  wire [5:0] n774;
  wire [5:0] n776;
  wire n778;
  wire n779;
  wire [2:0] n780;
  wire [39:0] n782;
  wire n784;
  wire [9:0] n785;
  wire n787;
  wire n789;
  wire n791;
  wire n793;
  wire [39:0] n795;
  wire [5:0] n798;
  wire n800;
  wire [2:0] n802;
  wire [39:0] n804;
  wire n807;
  wire [5:0] n809;
  wire [5:0] n811;
  wire [5:0] n813;
  wire [5:0] n814;
  wire n815;
  wire n816;
  wire [39:0] n818;
  wire n820;
  wire n822;
  wire [31:0] n823;
  wire n825;
  wire [7:0] n826;
  wire [7:0] n827;
  wire [7:0] n829;
  wire [5:0] n832;
  wire [7:0] n833;
  wire [7:0] n835;
  wire n837;
  wire [5:0] n840;
  wire [5:0] n843;
  wire n846;
  wire [7:0] n848;
  wire n850;
  wire n852;
  wire n853;
  wire n854;
  wire n855;
  wire [5:0] n857;
  wire n859;
  wire n861;
  wire [31:0] n862;
  wire n864;
  wire n865;
  wire [2:0] n866;
  wire n867;
  wire n868;
  wire n869;
  wire n870;
  wire n871;
  wire [3:0] n872;
  wire [1:0] n873;
  wire [5:0] n874;
  wire n875;
  wire n876;
  wire n877;
  wire [6:0] n878;
  wire [2:0] n879;
  wire n880;
  wire n881;
  wire n882;
  wire n883;
  wire n884;
  wire [3:0] n885;
  wire [5:0] n886;
  wire [9:0] n887;
  wire n888;
  wire n889;
  wire n890;
  wire n891;
  wire n892;
  wire [10:0] n893;
  wire [3:0] n894;
  wire [14:0] n895;
  wire n896;
  wire n897;
  wire n898;
  wire [15:0] n899;
  wire [6:0] n900;
  wire [7:0] n901;
  wire [2:0] n902;
  wire n903;
  wire n904;
  wire n905;
  wire n906;
  wire [3:0] n907;
  wire [5:0] n908;
  wire [9:0] n909;
  wire n910;
  wire n911;
  wire n912;
  wire n913;
  wire [10:0] n914;
  wire [3:0] n915;
  wire [14:0] n916;
  wire n917;
  wire n918;
  wire [15:0] n919;
  wire [31:0] n920;
  wire [31:0] n922;
  wire [6:0] n923;
  wire [5:0] n925;
  wire n928;
  wire [7:0] n929;
  wire [6:0] n930;
  wire [15:0] n931;
  wire [15:0] n932;
  wire [6:0] n934;
  wire n936;
  wire n938;
  wire [31:0] n939;
  wire n941;
  wire n942;
  wire [31:0] n943;
  wire n945;
  wire n946;
  wire n947;
  wire n948;
  wire n949;
  wire [31:0] n950;
  wire [31:0] n952;
  wire [9:0] n953;
  wire [31:0] n954;
  wire n956;
  wire [5:0] n959;
  wire n962;
  wire n964;
  wire [5:0] n966;
  wire [5:0] n968;
  wire n970;
  wire n973;
  wire n974;
  wire [9:0] n975;
  wire n978;
  wire [7:0] n980;
  wire [31:0] n981;
  wire [31:0] n983;
  wire [9:0] n984;
  wire [31:0] n985;
  wire n987;
  wire [5:0] n990;
  wire n993;
  wire n995;
  wire [5:0] n997;
  wire [5:0] n998;
  wire n999;
  wire n1001;
  wire n1002;
  wire [9:0] n1003;
  wire n1005;
  wire [7:0] n1007;
  wire [31:0] n1008;
  wire [31:0] n1010;
  wire [9:0] n1011;
  wire [5:0] n1012;
  wire [5:0] n1014;
  wire n1016;
  wire n1018;
  wire n1019;
  wire [9:0] n1020;
  wire n1022;
  wire [7:0] n1024;
  wire [31:0] n1025;
  wire [31:0] n1027;
  wire [7:0] n1028;
  wire [6:0] n1029;
  wire [7:0] n1031;
  wire [5:0] n1033;
  wire [5:0] n1035;
  wire n1037;
  wire n1039;
  wire n1040;
  wire [7:0] n1041;
  wire [9:0] n1042;
  wire n1044;
  wire [7:0] n1045;
  wire [31:0] n1046;
  wire [31:0] n1048;
  wire [6:0] n1049;
  wire [5:0] n1050;
  wire [5:0] n1052;
  wire n1054;
  wire n1057;
  wire n1059;
  wire n1060;
  wire [7:0] n1061;
  wire n1062;
  wire n1064;
  wire [7:0] n1065;
  wire [6:0] n1067;
  wire n1069;
  wire n1071;
  wire n1073;
  wire [31:0] n1074;
  wire n1076;
  wire [7:0] n1077;
  wire [31:0] n1078;
  wire [39:0] n1080;
  wire [5:0] n1083;
  wire [5:0] n1086;
  wire n1089;
  wire [39:0] n1091;
  wire n1094;
  wire [7:0] n1095;
  wire n1097;
  wire [7:0] n1099;
  wire n1101;
  wire n1103;
  wire n1104;
  wire n1105;
  wire [31:0] n1106;
  wire n1108;
  wire [5:0] n1110;
  wire [1:0] n1112;
  wire n1114;
  wire [2:0] n1116;
  wire [5:0] n1117;
  wire [1:0] n1118;
  wire n1119;
  wire [2:0] n1120;
  wire [5:0] n1122;
  wire [1:0] n1123;
  wire n1124;
  wire [2:0] n1125;
  wire n1127;
  wire n1129;
  wire [55:0] n1130;
  reg [5:0] n1162;
  reg [5:0] n1176;
  reg [5:0] n1195;
  reg n1211;
  reg n1231;
  reg n1235;
  reg n1240;
  reg n1243;
  reg n1250;
  reg [1:0] n1253;
  reg n1256;
  reg [2:0] n1259;
  reg n1262;
  reg n1265;
  reg [39:0] n1274;
  reg n1290;
  reg [7:0] n1293;
  reg [6:0] n1296;
  reg [15:0] n1299;
  reg [15:0] n1302;
  reg [7:0] n1304;
  reg [7:0] n1309;
  reg [31:0] n1313;
  reg [7:0] n1316;
  reg n1320;
  reg [9:0] n1328;
  reg n1336;
  reg [7:0] n1341;
  reg n1345;
  reg [6:0] n1348;
  reg n1350;
  reg n1353;
  wire n1357;
  wire n1360;
  wire n1363;
  wire n1366;
  wire n1369;
  wire n1372;
  wire n1375;
  wire n1378;
  wire n1381;
  wire n1384;
  wire n1387;
  wire n1390;
  wire n1393;
  wire n1396;
  wire n1399;
  wire n1402;
  wire n1405;
  wire n1408;
  wire n1411;
  wire n1414;
  wire n1417;
  wire n1420;
  wire n1423;
  wire n1426;
  wire n1429;
  wire n1432;
  wire n1435;
  wire n1438;
  wire n1441;
  wire n1444;
  wire n1447;
  wire n1450;
  wire n1453;
  wire n1456;
  wire n1459;
  wire n1462;
  wire n1465;
  wire n1468;
  wire n1471;
  wire n1474;
  wire n1477;
  wire n1480;
  wire n1483;
  wire n1486;
  wire n1489;
  wire n1492;
  wire n1495;
  wire n1498;
  wire n1501;
  wire n1504;
  wire n1507;
  wire n1510;
  wire n1513;
  wire n1516;
  wire n1519;
  wire n1522;
  wire [55:0] n1523;
  reg [7:0] n1525;
  reg n1526;
  reg n1527;
  reg n1528;
  reg [7:0] n1529;
  reg n1530;
  reg n1531;
  reg n1532;
  reg n1533;
  reg [2:0] n1534;
  reg [1:0] n1535;
  reg [5:0] n1536;
  reg [5:0] n1537;
  reg [5:0] n1538;
  reg n1539;
  reg n1540;
  reg n1541;
  reg [1:0] n1542;
  reg n1543;
  reg [2:0] n1544;
  reg n1545;
  reg [39:0] n1546;
  reg [7:0] n1547;
  reg [6:0] n1548;
  reg [15:0] n1549;
  reg [15:0] n1550;
  reg [7:0] n1551;
  reg [7:0] n1552;
  reg [31:0] n1553;
  reg [7:0] n1554;
  reg [9:0] n1555;
  reg [7:0] n1556;
  reg n1557;
  reg [6:0] n1558;
  reg n1559;
  reg n1560;
  reg n1561;
  reg n1562;
  assign cs = n1526; //(module output)
  assign mosi = n1527; //(module output)
  assign sclk = n1528; //(module output)
  assign dout = n1529; //(module output)
  assign dout_avail = n1530; //(module output)
  assign din_taken = n1531; //(module output)
  assign sd_error = n1532; //(module output)
  assign sd_busy = n1533; //(module output)
  assign sd_error_code = n1534; //(module output)
  assign sd_type = n1535; //(module output)
  assign sd_fsm = n1525; //(module output)
  /* sd_spi.vhd:224:8  */
  always @*
    state = n1536; // (isignal)
  initial
    state = 6'b000000;
  /* sd_spi.vhd:224:15  */
  always @*
    new_state = n1162; // (isignal)
  initial
    new_state = 6'b000000;
  /* sd_spi.vhd:224:26  */
  always @*
    return_state = n1537; // (isignal)
  initial
    return_state = 6'b000000;
  /* sd_spi.vhd:224:40  */
  always @*
    new_return_state = n1176; // (isignal)
  initial
    new_return_state = 6'b000000;
  /* sd_spi.vhd:224:58  */
  always @*
    sr_return_state = n1538; // (isignal)
  initial
    sr_return_state = 6'b000000;
  /* sd_spi.vhd:224:75  */
  always @*
    new_sr_return_state = n1195; // (isignal)
  initial
    new_sr_return_state = 6'b000000;
  /* sd_spi.vhd:225:8  */
  always @*
    set_return_state = n1211; // (isignal)
  initial
    set_return_state = 1'b0;
  /* sd_spi.vhd:225:26  */
  always @*
    set_sr_return_state = n1231; // (isignal)
  initial
    set_sr_return_state = 1'b0;
  /* sd_spi.vhd:228:8  */
  always @*
    new_sclk = n1235; // (isignal)
  initial
    new_sclk = 1'b0;
  /* sd_spi.vhd:229:8  */
  always @*
    scs = n1539; // (isignal)
  initial
    scs = 1'b1;
  /* sd_spi.vhd:229:13  */
  always @*
    new_cs = n1240; // (isignal)
  initial
    new_cs = 1'b1;
  /* sd_spi.vhd:232:8  */
  always @*
    set_davail = n1243; // (isignal)
  initial
    set_davail = 1'b0;
  /* sd_spi.vhd:233:8  */
  always @*
    sdavail = n1540; // (isignal)
  initial
    sdavail = 1'b0;
  /* sd_spi.vhd:234:8  */
  always @*
    transfer_data_out = n1541; // (isignal)
  initial
    transfer_data_out = 1'b0;
  /* sd_spi.vhd:234:27  */
  always @*
    new_transfer_data_out = n1250; // (isignal)
  initial
    new_transfer_data_out = 1'b0;
  /* sd_spi.vhd:235:8  */
  always @*
    card_type = n1542; // (isignal)
  initial
    card_type = 2'b00;
  /* sd_spi.vhd:235:19  */
  always @*
    new_card_type = n1253; // (isignal)
  initial
    new_card_type = 2'b00;
  /* sd_spi.vhd:236:8  */
  always @*
    error = n1543; // (isignal)
  initial
    error = 1'b0;
  /* sd_spi.vhd:236:15  */
  always @*
    new_error = n1256; // (isignal)
  initial
    new_error = 1'b0;
  /* sd_spi.vhd:237:8  */
  always @*
    error_code = n1544; // (isignal)
  initial
    error_code = 3'b000;
  /* sd_spi.vhd:237:20  */
  always @*
    new_error_code = n1259; // (isignal)
  initial
    new_error_code = 3'b000;
  /* sd_spi.vhd:238:8  */
  always @*
    new_busy = n1262; // (isignal)
  initial
    new_busy = 1'b1;
  /* sd_spi.vhd:239:8  */
  always @*
    sdin_taken = n1545; // (isignal)
  initial
    sdin_taken = 1'b0;
  /* sd_spi.vhd:239:20  */
  always @*
    new_din_taken = n1265; // (isignal)
  initial
    new_din_taken = 1'b0;
  /* sd_spi.vhd:242:8  */
  always @*
    cmd_out = n1546; // (isignal)
  initial
    cmd_out = 40'b1111111111111111111111111111111111111111;
  /* sd_spi.vhd:242:17  */
  always @*
    new_cmd_out = n1274; // (isignal)
  initial
    new_cmd_out = 40'b1111111111111111111111111111111111111111;
  /* sd_spi.vhd:243:8  */
  always @*
    set_cmd_out = n1290; // (isignal)
  initial
    set_cmd_out = 1'b0;
  /* sd_spi.vhd:244:8  */
  assign data_in = n1547; // (signal)
  /* sd_spi.vhd:244:17  */
  assign new_data_in = n1293; // (signal)
  /* sd_spi.vhd:245:8  */
  assign new_crc7 = n1296; // (signal)
  /* sd_spi.vhd:245:18  */
  assign crc7 = n1548; // (signal)
  /* sd_spi.vhd:246:8  */
  assign new_in_crc16 = n1299; // (signal)
  /* sd_spi.vhd:246:22  */
  assign in_crc16 = n1549; // (signal)
  /* sd_spi.vhd:247:8  */
  assign new_out_crc16 = n1302; // (signal)
  /* sd_spi.vhd:247:23  */
  assign out_crc16 = n1550; // (signal)
  /* sd_spi.vhd:248:8  */
  assign new_crclow = n1304; // (signal)
  /* sd_spi.vhd:248:20  */
  assign crclow = n1551; // (signal)
  /* sd_spi.vhd:249:8  */
  always @*
    data_out = n1552; // (isignal)
  initial
    data_out = 8'b00000000;
  /* sd_spi.vhd:249:18  */
  always @*
    new_data_out = n1309; // (isignal)
  initial
    new_data_out = 8'b00000000;
  /* sd_spi.vhd:251:8  */
  assign address = n1553; // (signal)
  /* sd_spi.vhd:251:17  */
  assign new_address = n1313; // (signal)
  /* sd_spi.vhd:252:8  */
  assign wr_erase_count = n1554; // (signal)
  /* sd_spi.vhd:252:24  */
  assign new_wr_erase_count = n1316; // (signal)
  /* sd_spi.vhd:253:8  */
  always @*
    set_address = n1320; // (isignal)
  initial
    set_address = 1'b0;
  /* sd_spi.vhd:254:8  */
  always @*
    byte_counter = n1555; // (isignal)
  initial
    byte_counter = 10'b0000000000;
  /* sd_spi.vhd:254:22  */
  always @*
    new_byte_counter = n1328; // (isignal)
  initial
    new_byte_counter = 10'b0000000000;
  /* sd_spi.vhd:255:8  */
  always @*
    set_byte_counter = n1336; // (isignal)
  initial
    set_byte_counter = 1'b0;
  /* sd_spi.vhd:256:8  */
  always @*
    bit_counter = n1556; // (isignal)
  initial
    bit_counter = 8'b00000000;
  /* sd_spi.vhd:256:21  */
  always @*
    new_bit_counter = n1341; // (isignal)
  initial
    new_bit_counter = 8'b00000000;
  /* sd_spi.vhd:257:8  */
  always @*
    slow_clock = n1557; // (isignal)
  initial
    slow_clock = 1'b1;
  /* sd_spi.vhd:257:20  */
  always @*
    new_slow_clock = n1345; // (isignal)
  initial
    new_slow_clock = 1'b1;
  /* sd_spi.vhd:258:8  */
  always @*
    clock_divider = n1558; // (isignal)
  initial
    clock_divider = 7'b0000000;
  /* sd_spi.vhd:258:23  */
  always @*
    new_clock_divider = n1348; // (isignal)
  initial
    new_clock_divider = 7'b0000000;
  /* sd_spi.vhd:259:8  */
  always @*
    multiple = n1559; // (isignal)
  initial
    multiple = 1'b0;
  /* sd_spi.vhd:259:18  */
  always @*
    new_multiple = n1350; // (isignal)
  initial
    new_multiple = 1'b0;
  /* sd_spi.vhd:260:8  */
  always @*
    skipfirstr1byte = n1560; // (isignal)
  initial
    skipfirstr1byte = 1'b0;
  /* sd_spi.vhd:260:25  */
  always @*
    new_skipfirstr1byte = n1353; // (isignal)
  initial
    new_skipfirstr1byte = 1'b0;
  /* sd_spi.vhd:261:8  */
  always @*
    din_latch = n1561; // (isignal)
  initial
    din_latch = 1'b0;
  /* sd_spi.vhd:262:8  */
  always @*
    last_din_valid = n1562; // (isignal)
  initial
    last_din_valid = 1'b0;
  /* sd_spi.vhd:313:33  */
  assign n59 = set_return_state ? new_return_state : return_state;
  /* sd_spi.vhd:314:33  */
  assign n60 = set_sr_return_state ? new_sr_return_state : sr_return_state;
  /* sd_spi.vhd:315:33  */
  assign n61 = set_cmd_out ? new_cmd_out : cmd_out;
  /* sd_spi.vhd:317:33  */
  assign n62 = set_address ? new_address : address;
  /* sd_spi.vhd:319:33  */
  assign n63 = set_byte_counter ? new_byte_counter : byte_counter;
  /* sd_spi.vhd:335:53  */
  assign n64 = new_data_out[7]; // extract
  /* sd_spi.vhd:346:51  */
  assign n65 = dout_taken & sdavail;
  /* sd_spi.vhd:346:33  */
  assign n67 = n65 ? 1'b0 : n1530;
  /* sd_spi.vhd:346:33  */
  assign n69 = n65 ? 1'b0 : sdavail;
  /* sd_spi.vhd:342:33  */
  assign n70 = set_davail ? data_in : n1529;
  /* sd_spi.vhd:342:33  */
  assign n72 = set_davail ? 1'b1 : n67;
  /* sd_spi.vhd:342:33  */
  assign n74 = set_davail ? 1'b1 : n69;
  /* sd_spi.vhd:354:45  */
  assign n75 = ~din_valid;
  /* sd_spi.vhd:354:56  */
  assign n76 = ~wr;
  /* sd_spi.vhd:354:76  */
  assign n77 = ~wr_multiple;
  /* sd_spi.vhd:354:61  */
  assign n78 = n77 & n76;
  /* sd_spi.vhd:354:50  */
  assign n79 = n75 | n78;
  /* sd_spi.vhd:359:71  */
  assign n80 = ~last_din_valid;
  /* sd_spi.vhd:359:53  */
  assign n81 = n80 & din_valid;
  /* sd_spi.vhd:364:49  */
  assign n82 = new_din_taken & din_latch;
  /* sd_spi.vhd:364:33  */
  assign n84 = n82 ? 1'b1 : n1531;
  /* sd_spi.vhd:364:33  */
  assign n86 = n82 ? 1'b1 : sdin_taken;
  /* sd_spi.vhd:364:33  */
  assign n88 = n82 ? 1'b0 : din_latch;
  /* sd_spi.vhd:359:33  */
  assign n90 = n81 ? 1'b0 : n84;
  /* sd_spi.vhd:359:33  */
  assign n92 = n81 ? 1'b0 : n86;
  /* sd_spi.vhd:359:33  */
  assign n94 = n81 ? 1'b1 : n88;
  /* sd_spi.vhd:354:33  */
  assign n96 = n79 ? 1'b0 : n90;
  /* sd_spi.vhd:354:33  */
  assign n98 = n79 ? 1'b0 : n92;
  /* sd_spi.vhd:354:33  */
  assign n100 = n79 ? 1'b0 : n94;
  /* sd_spi.vhd:270:25  */
  assign n102 = reset ? 1'b1 : new_cs;
  /* sd_spi.vhd:270:25  */
  assign n104 = reset ? 1'b1 : n64;
  /* sd_spi.vhd:270:25  */
  assign n106 = reset ? 1'b0 : new_sclk;
  /* sd_spi.vhd:270:25  */
  assign n108 = reset ? 8'b00000000 : n70;
  /* sd_spi.vhd:270:25  */
  assign n110 = reset ? 1'b0 : n72;
  /* sd_spi.vhd:270:25  */
  assign n112 = reset ? 1'b0 : n96;
  /* sd_spi.vhd:270:25  */
  assign n114 = reset ? 1'b1 : new_error;
  /* sd_spi.vhd:270:25  */
  assign n116 = reset ? 1'b1 : new_busy;
  /* sd_spi.vhd:270:25  */
  assign n118 = reset ? 3'b111 : new_error_code;
  /* sd_spi.vhd:270:25  */
  assign n120 = reset ? 2'b00 : new_card_type;
  /* sd_spi.vhd:270:25  */
  assign n122 = reset ? 6'b000000 : new_state;
  /* sd_spi.vhd:270:25  */
  assign n124 = reset ? 6'b000000 : n59;
  /* sd_spi.vhd:270:25  */
  assign n126 = reset ? 6'b000000 : n60;
  /* sd_spi.vhd:270:25  */
  assign n128 = reset ? 1'b1 : new_cs;
  /* sd_spi.vhd:270:25  */
  assign n130 = reset ? 1'b0 : n74;
  /* sd_spi.vhd:270:25  */
  assign n132 = reset ? 1'b0 : new_transfer_data_out;
  /* sd_spi.vhd:270:25  */
  assign n134 = reset ? 2'b00 : new_card_type;
  /* sd_spi.vhd:270:25  */
  assign n136 = reset ? 1'b0 : new_error;
  /* sd_spi.vhd:270:25  */
  assign n138 = reset ? 3'b111 : new_error_code;
  /* sd_spi.vhd:270:25  */
  assign n140 = reset ? 1'b0 : n98;
  /* sd_spi.vhd:270:25  */
  assign n142 = reset ? 40'b1111111111111111111111111111111111111111 : n61;
  /* sd_spi.vhd:270:25  */
  assign n144 = reset ? 8'b00000000 : new_data_in;
  /* sd_spi.vhd:270:25  */
  assign n146 = reset ? 7'b0000000 : new_crc7;
  /* sd_spi.vhd:270:25  */
  assign n148 = reset ? 16'b0000000000000000 : new_in_crc16;
  /* sd_spi.vhd:270:25  */
  assign n150 = reset ? 16'b0000000000000000 : new_out_crc16;
  /* sd_spi.vhd:270:25  */
  assign n152 = reset ? 8'b00000000 : new_crclow;
  /* sd_spi.vhd:270:25  */
  assign n154 = reset ? 8'b11111111 : new_data_out;
  /* sd_spi.vhd:270:25  */
  assign n156 = reset ? 32'b00000000000000000000000000000000 : n62;
  /* sd_spi.vhd:270:25  */
  assign n158 = reset ? 8'b00000001 : new_wr_erase_count;
  /* sd_spi.vhd:270:25  */
  assign n160 = reset ? 10'b0000000000 : n63;
  /* sd_spi.vhd:270:25  */
  assign n162 = reset ? 8'b00000000 : new_bit_counter;
  /* sd_spi.vhd:270:25  */
  assign n164 = reset ? 1'b1 : new_slow_clock;
  /* sd_spi.vhd:270:25  */
  assign n166 = reset ? 7'b0000000 : new_clock_divider;
  /* sd_spi.vhd:270:25  */
  assign n168 = reset ? 1'b0 : new_multiple;
  /* sd_spi.vhd:270:25  */
  assign n170 = reset ? 1'b0 : new_skipfirstr1byte;
  /* sd_spi.vhd:270:25  */
  assign n171 = reset ? din_latch : n100;
  /* sd_spi.vhd:270:25  */
  assign n172 = reset ? last_din_valid : din_valid;
  /* sd_spi.vhd:389:17  */
  always @*
    if (!1'b1)
      $fatal(1, "assertion failure n213");
  /* sd_spi.vhd:425:17  */
  assign n215 = state == 6'b000000;
  /* sd_spi.vhd:441:25  */
  assign n217 = card_present ? 6'b100001 : state;
  /* sd_spi.vhd:431:17  */
  assign n219 = state == 6'b000001;
  /* sd_spi.vhd:447:40  */
  assign n220 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:447:40  */
  assign n222 = n220 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:447:25  */
  assign n225 = n222 ? 6'b000011 : 6'b100001;
  /* sd_spi.vhd:446:17  */
  assign n227 = state == 6'b000010;
  /* sd_spi.vhd:453:17  */
  assign n229 = state == 6'b000011;
  /* sd_spi.vhd:463:35  */
  assign n231 = data_in == 8'b00000001;
  /* sd_spi.vhd:463:25  */
  assign n234 = n231 ? 6'b100011 : 6'b000001;
  /* sd_spi.vhd:463:25  */
  assign n237 = n231 ? 6'b000101 : 6'b000000;
  /* sd_spi.vhd:463:25  */
  assign n240 = n231 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:463:25  */
  assign n242 = n231 ? card_type : 2'b00;
  /* sd_spi.vhd:463:25  */
  assign n244 = n231 ? error : 1'b1;
  /* sd_spi.vhd:463:25  */
  assign n246 = n231 ? error_code : 3'b001;
  /* sd_spi.vhd:463:25  */
  assign n249 = n231 ? 40'b0100100000000000000000000000000110101010 : 40'bX;
  /* sd_spi.vhd:463:25  */
  assign n252 = n231 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:461:17  */
  assign n254 = state == 6'b000100;
  /* sd_spi.vhd:476:35  */
  assign n255 = data_in[2]; // extract
  /* sd_spi.vhd:476:25  */
  assign n258 = n255 ? 6'b001010 : 6'b100001;
  /* sd_spi.vhd:476:25  */
  assign n261 = n255 ? 6'b000000 : 6'b000110;
  /* sd_spi.vhd:476:25  */
  assign n264 = n255 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:476:25  */
  assign n267 = n255 ? 2'b01 : 2'b10;
  /* sd_spi.vhd:474:17  */
  assign n269 = state == 6'b000101;
  /* sd_spi.vhd:485:17  */
  assign n271 = state == 6'b000110;
  /* sd_spi.vhd:490:17  */
  assign n273 = state == 6'b000111;
  /* sd_spi.vhd:495:17  */
  assign n280 = state == 6'b001000;
  /* sd_spi.vhd:508:36  */
  assign n282 = data_in == 8'b10101010;
  /* sd_spi.vhd:508:25  */
  assign n285 = n282 ? 6'b001010 : 6'b000000;
  /* sd_spi.vhd:505:17  */
  assign n287 = state == 6'b001001;
  /* sd_spi.vhd:514:17  */
  assign n289 = state == 6'b001010;
  /* sd_spi.vhd:523:37  */
  assign n291 = card_type == 2'b01;
  /* sd_spi.vhd:523:25  */
  assign n294 = n291 ? 40'b0110100100000000000000000000000000000000 : 40'b0110100101000000000000000000000000000000;
  /* sd_spi.vhd:520:17  */
  assign n296 = state == 6'b001011;
  /* sd_spi.vhd:533:36  */
  assign n297 = data_in[0]; // extract
  /* sd_spi.vhd:533:46  */
  assign n298 = ~n297;
  /* sd_spi.vhd:534:46  */
  assign n300 = card_type == 2'b01;
  /* sd_spi.vhd:534:33  */
  assign n303 = n300 ? 6'b010010 : 6'b001101;
  /* sd_spi.vhd:533:25  */
  assign n305 = n298 ? n303 : 6'b001010;
  /* sd_spi.vhd:531:17  */
  assign n307 = state == 6'b001100;
  /* sd_spi.vhd:543:17  */
  assign n309 = state == 6'b001101;
  /* sd_spi.vhd:551:35  */
  assign n310 = data_in[2]; // extract
  /* sd_spi.vhd:551:25  */
  assign n313 = n310 ? 6'b000001 : 6'b100001;
  /* sd_spi.vhd:551:25  */
  assign n316 = n310 ? 6'b000000 : 6'b001111;
  /* sd_spi.vhd:551:25  */
  assign n319 = n310 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:551:25  */
  assign n321 = n310 ? 2'b00 : card_type;
  /* sd_spi.vhd:551:25  */
  assign n323 = n310 ? 1'b1 : error;
  /* sd_spi.vhd:551:25  */
  assign n325 = n310 ? 3'b110 : error_code;
  /* sd_spi.vhd:549:17  */
  assign n327 = state == 6'b001110;
  /* sd_spi.vhd:566:36  */
  assign n328 = data_in[6]; // extract
  /* sd_spi.vhd:566:25  */
  assign n330 = n328 ? 2'b11 : card_type;
  /* sd_spi.vhd:563:17  */
  assign n332 = state == 6'b001111;
  /* sd_spi.vhd:573:17  */
  assign n334 = state == 6'b010000;
  /* sd_spi.vhd:578:17  */
  assign n336 = state == 6'b010001;
  /* sd_spi.vhd:583:17  */
  assign n338 = state == 6'b010010;
  /* sd_spi.vhd:591:35  */
  assign n340 = data_in != 8'b00000000;
  /* sd_spi.vhd:591:25  */
  assign n342 = n340 ? 6'b000000 : state;
  /* sd_spi.vhd:595:31  */
  assign n343 = ~rd;
  /* sd_spi.vhd:595:44  */
  assign n344 = ~wr;
  /* sd_spi.vhd:595:37  */
  assign n345 = n344 & n343;
  /* sd_spi.vhd:595:66  */
  assign n346 = ~rd_multiple;
  /* sd_spi.vhd:595:50  */
  assign n347 = n346 & n345;
  /* sd_spi.vhd:595:88  */
  assign n348 = ~wr_multiple;
  /* sd_spi.vhd:595:72  */
  assign n349 = n348 & n347;
  /* sd_spi.vhd:595:25  */
  assign n351 = n349 ? 6'b010100 : n342;
  /* sd_spi.vhd:595:25  */
  assign n353 = n349 ? 1'b0 : error;
  /* sd_spi.vhd:595:25  */
  assign n355 = n349 ? 3'b000 : error_code;
  /* sd_spi.vhd:589:17  */
  assign n357 = state == 6'b010011;
  /* sd_spi.vhd:601:17  */
  assign n359 = state == 6'b010100;
  /* sd_spi.vhd:612:40  */
  assign n360 = ~card_present;
  /* sd_spi.vhd:615:38  */
  assign n362 = data_in == 8'b00000000;
  /* sd_spi.vhd:634:38  */
  assign n363 = wr | wr_multiple;
  /* sd_spi.vhd:636:51  */
  assign n364 = ~card_write_prot;
  /* sd_spi.vhd:641:41  */
  assign n366 = wr ? 8'b00000001 : erase_count;
  /* sd_spi.vhd:641:41  */
  assign n369 = wr ? 1'b0 : 1'b1;
  /* sd_spi.vhd:634:25  */
  assign n371 = n387 ? 6'b101001 : state;
  /* sd_spi.vhd:636:33  */
  assign n373 = n364 ? 1'b0 : scs;
  /* sd_spi.vhd:636:33  */
  assign n376 = n364 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:636:33  */
  assign n379 = n364 ? 3'b000 : 3'b101;
  /* sd_spi.vhd:636:33  */
  assign n381 = n364 ? addr : 32'bX;
  /* sd_spi.vhd:634:25  */
  assign n382 = n397 ? n366 : wr_erase_count;
  /* sd_spi.vhd:636:33  */
  assign n385 = n364 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:634:25  */
  assign n386 = n400 ? n369 : multiple;
  /* sd_spi.vhd:634:25  */
  assign n387 = n364 & n363;
  /* sd_spi.vhd:634:25  */
  assign n389 = n363 ? n373 : 1'b1;
  /* sd_spi.vhd:634:25  */
  assign n390 = n363 ? n376 : error;
  /* sd_spi.vhd:634:25  */
  assign n391 = n363 ? n379 : error_code;
  /* sd_spi.vhd:634:25  */
  assign n394 = n363 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:634:25  */
  assign n396 = n363 ? n381 : 32'bX;
  /* sd_spi.vhd:634:25  */
  assign n397 = n364 & n363;
  /* sd_spi.vhd:634:25  */
  assign n399 = n363 ? n385 : 1'b0;
  /* sd_spi.vhd:634:25  */
  assign n400 = n364 & n363;
  /* sd_spi.vhd:626:25  */
  assign n402 = rd_multiple ? 6'b010111 : n371;
  /* sd_spi.vhd:626:25  */
  assign n404 = rd_multiple ? 1'b0 : n389;
  /* sd_spi.vhd:626:25  */
  assign n406 = rd_multiple ? 1'b0 : n390;
  /* sd_spi.vhd:626:25  */
  assign n408 = rd_multiple ? 3'b000 : n391;
  /* sd_spi.vhd:626:25  */
  assign n410 = rd_multiple ? 1'b1 : n394;
  /* sd_spi.vhd:626:25  */
  assign n411 = rd_multiple ? addr : n396;
  /* sd_spi.vhd:626:25  */
  assign n412 = rd_multiple ? wr_erase_count : n382;
  /* sd_spi.vhd:626:25  */
  assign n414 = rd_multiple ? 1'b1 : n399;
  /* sd_spi.vhd:626:25  */
  assign n416 = rd_multiple ? 1'b1 : n386;
  /* sd_spi.vhd:618:25  */
  assign n418 = rd ? 6'b010110 : n402;
  /* sd_spi.vhd:618:25  */
  assign n420 = rd ? 1'b0 : n404;
  /* sd_spi.vhd:618:25  */
  assign n422 = rd ? 1'b0 : n406;
  /* sd_spi.vhd:618:25  */
  assign n424 = rd ? 3'b000 : n408;
  /* sd_spi.vhd:618:25  */
  assign n426 = rd ? 1'b1 : n410;
  /* sd_spi.vhd:618:25  */
  assign n427 = rd ? addr : n411;
  /* sd_spi.vhd:618:25  */
  assign n428 = rd ? wr_erase_count : n412;
  /* sd_spi.vhd:618:25  */
  assign n430 = rd ? 1'b1 : n414;
  /* sd_spi.vhd:618:25  */
  assign n432 = rd ? 1'b0 : n416;
  /* sd_spi.vhd:615:25  */
  assign n434 = n362 ? 6'b010100 : n418;
  /* sd_spi.vhd:615:25  */
  assign n435 = n362 ? scs : n420;
  /* sd_spi.vhd:615:25  */
  assign n436 = n362 ? error : n422;
  /* sd_spi.vhd:615:25  */
  assign n437 = n362 ? error_code : n424;
  /* sd_spi.vhd:615:25  */
  assign n439 = n362 ? 1'b1 : n426;
  /* sd_spi.vhd:615:25  */
  assign n441 = n362 ? 32'bX : n427;
  /* sd_spi.vhd:615:25  */
  assign n442 = n362 ? wr_erase_count : n428;
  /* sd_spi.vhd:615:25  */
  assign n444 = n362 ? 1'b0 : n430;
  /* sd_spi.vhd:615:25  */
  assign n445 = n362 ? multiple : n432;
  /* sd_spi.vhd:612:25  */
  assign n447 = n360 ? 6'b000000 : n434;
  /* sd_spi.vhd:612:25  */
  assign n448 = n360 ? scs : n435;
  /* sd_spi.vhd:612:25  */
  assign n449 = n360 ? error : n436;
  /* sd_spi.vhd:612:25  */
  assign n450 = n360 ? error_code : n437;
  /* sd_spi.vhd:612:25  */
  assign n452 = n360 ? 1'b1 : n439;
  /* sd_spi.vhd:612:25  */
  assign n454 = n360 ? 32'bX : n441;
  /* sd_spi.vhd:612:25  */
  assign n455 = n360 ? wr_erase_count : n442;
  /* sd_spi.vhd:612:25  */
  assign n457 = n360 ? 1'b0 : n444;
  /* sd_spi.vhd:612:25  */
  assign n458 = n360 ? multiple : n445;
  /* sd_spi.vhd:610:17  */
  assign n460 = state == 6'b010101;
  /* sd_spi.vhd:661:37  */
  assign n462 = card_type == 2'b11;
  /* sd_spi.vhd:663:54  */
  assign n464 = {8'b01010001, address};
  /* sd_spi.vhd:666:63  */
  assign n465 = address[22:0]; // extract
  /* sd_spi.vhd:666:54  */
  assign n467 = {8'b01010001, n465};
  /* sd_spi.vhd:666:77  */
  assign n469 = {n467, 9'b000000000};
  /* sd_spi.vhd:661:25  */
  assign n470 = n462 ? n464 : n469;
  /* sd_spi.vhd:659:17  */
  assign n472 = state == 6'b010110;
  /* sd_spi.vhd:674:37  */
  assign n474 = card_type == 2'b11;
  /* sd_spi.vhd:676:54  */
  assign n476 = {8'b01010010, address};
  /* sd_spi.vhd:679:63  */
  assign n477 = address[22:0]; // extract
  /* sd_spi.vhd:679:54  */
  assign n479 = {8'b01010010, n477};
  /* sd_spi.vhd:679:77  */
  assign n481 = {n479, 9'b000000000};
  /* sd_spi.vhd:674:25  */
  assign n482 = n474 ? n476 : n481;
  /* sd_spi.vhd:672:17  */
  assign n484 = state == 6'b010111;
  /* sd_spi.vhd:687:35  */
  assign n486 = data_in != 8'b00000000;
  /* sd_spi.vhd:687:25  */
  assign n489 = n486 ? 6'b011110 : 6'b100001;
  /* sd_spi.vhd:687:25  */
  assign n492 = n486 ? 6'b000000 : 6'b011001;
  /* sd_spi.vhd:687:25  */
  assign n495 = n486 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:687:25  */
  assign n497 = n486 ? 1'b1 : error;
  /* sd_spi.vhd:687:25  */
  assign n499 = n486 ? 3'b001 : error_code;
  /* sd_spi.vhd:685:17  */
  assign n501 = state == 6'b011000;
  /* sd_spi.vhd:699:30  */
  assign n502 = ~rd;
  /* sd_spi.vhd:699:50  */
  assign n503 = ~rd_multiple;
  /* sd_spi.vhd:699:35  */
  assign n504 = n503 & n502;
  /* sd_spi.vhd:702:39  */
  assign n506 = data_in == 8'b11111110;
  /* sd_spi.vhd:707:39  */
  assign n507 = data_in[7:4]; // extract
  /* sd_spi.vhd:707:51  */
  assign n509 = n507 == 4'b0000;
  /* sd_spi.vhd:707:25  */
  assign n512 = n509 ? 6'b011110 : 6'b100001;
  /* sd_spi.vhd:707:25  */
  assign n514 = n509 ? 1'b1 : error;
  /* sd_spi.vhd:707:25  */
  assign n516 = n509 ? 3'b100 : error_code;
  /* sd_spi.vhd:702:25  */
  assign n518 = n506 ? 6'b100001 : n512;
  /* sd_spi.vhd:702:25  */
  assign n521 = n506 ? 6'b011010 : 6'b000000;
  /* sd_spi.vhd:702:25  */
  assign n524 = n506 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:702:25  */
  assign n526 = n506 ? 1'b1 : transfer_data_out;
  /* sd_spi.vhd:702:25  */
  assign n527 = n506 ? error : n514;
  /* sd_spi.vhd:702:25  */
  assign n528 = n506 ? error_code : n516;
  /* sd_spi.vhd:702:25  */
  assign n530 = n506 ? 10'b1000000000 : byte_counter;
  /* sd_spi.vhd:702:25  */
  assign n533 = n506 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:699:25  */
  assign n535 = n504 ? 6'b011110 : n518;
  /* sd_spi.vhd:699:25  */
  assign n537 = n504 ? 6'b000000 : n521;
  /* sd_spi.vhd:699:25  */
  assign n539 = n504 ? 1'b0 : n524;
  /* sd_spi.vhd:699:25  */
  assign n540 = n504 ? transfer_data_out : n526;
  /* sd_spi.vhd:699:25  */
  assign n541 = n504 ? error : n527;
  /* sd_spi.vhd:699:25  */
  assign n542 = n504 ? error_code : n528;
  /* sd_spi.vhd:699:25  */
  assign n543 = n504 ? byte_counter : n530;
  /* sd_spi.vhd:699:25  */
  assign n545 = n504 ? 1'b0 : n533;
  /* sd_spi.vhd:696:17  */
  assign n547 = state == 6'b011001;
  /* sd_spi.vhd:719:30  */
  assign n548 = ~rd;
  /* sd_spi.vhd:719:50  */
  assign n549 = ~rd_multiple;
  /* sd_spi.vhd:719:35  */
  assign n550 = n549 & n548;
  /* sd_spi.vhd:723:48  */
  assign n551 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:723:48  */
  assign n553 = n551 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:723:33  */
  assign n556 = n553 ? 6'b011100 : 6'b000000;
  /* sd_spi.vhd:723:33  */
  assign n559 = n553 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:723:33  */
  assign n561 = n553 ? 1'b0 : transfer_data_out;
  /* sd_spi.vhd:719:25  */
  assign n564 = n550 ? 6'b011011 : 6'b100001;
  /* sd_spi.vhd:719:25  */
  assign n566 = n550 ? 6'b000000 : n556;
  /* sd_spi.vhd:719:25  */
  assign n568 = n550 ? 1'b0 : n559;
  /* sd_spi.vhd:719:25  */
  assign n569 = n550 ? transfer_data_out : n561;
  /* sd_spi.vhd:717:17  */
  assign n571 = state == 6'b011010;
  /* sd_spi.vhd:737:44  */
  assign n572 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:737:44  */
  assign n574 = n572 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:737:25  */
  assign n577 = n574 ? 6'b011100 : 6'b011011;
  /* sd_spi.vhd:734:25  */
  assign n580 = multiple ? 6'b011111 : 6'b100001;
  /* sd_spi.vhd:734:25  */
  assign n582 = multiple ? 6'b000000 : n577;
  /* sd_spi.vhd:734:25  */
  assign n585 = multiple ? 1'b0 : 1'b1;
  /* sd_spi.vhd:731:17  */
  assign n587 = state == 6'b011011;
  /* sd_spi.vhd:747:17  */
  assign n589 = state == 6'b011100;
  /* sd_spi.vhd:754:36  */
  assign n591 = in_crc16 != 16'b0000000000000000;
  /* sd_spi.vhd:758:40  */
  assign n592 = rd_multiple & multiple;
  /* sd_spi.vhd:758:25  */
  assign n595 = n592 ? 6'b100001 : 6'b011110;
  /* sd_spi.vhd:758:25  */
  assign n598 = n592 ? 6'b011001 : 6'b000000;
  /* sd_spi.vhd:758:25  */
  assign n601 = n592 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:754:25  */
  assign n603 = n591 ? 6'b011110 : n595;
  /* sd_spi.vhd:754:25  */
  assign n605 = n591 ? 6'b000000 : n598;
  /* sd_spi.vhd:754:25  */
  assign n607 = n591 ? 1'b0 : n601;
  /* sd_spi.vhd:754:25  */
  assign n609 = n591 ? 1'b1 : error;
  /* sd_spi.vhd:754:25  */
  assign n611 = n591 ? 3'b010 : error_code;
  /* sd_spi.vhd:752:17  */
  assign n613 = state == 6'b011101;
  /* sd_spi.vhd:770:31  */
  assign n614 = ~rd;
  /* sd_spi.vhd:770:53  */
  assign n615 = ~rd_multiple;
  /* sd_spi.vhd:770:37  */
  assign n616 = n615 & n614;
  /* sd_spi.vhd:771:33  */
  assign n619 = multiple ? 6'b011111 : 6'b010100;
  /* sd_spi.vhd:770:25  */
  assign n620 = n616 ? n619 : state;
  /* sd_spi.vhd:767:17  */
  assign n622 = state == 6'b011110;
  /* sd_spi.vhd:778:17  */
  assign n624 = state == 6'b011111;
  /* sd_spi.vhd:787:35  */
  assign n626 = data_in != 8'b00000000;
  /* sd_spi.vhd:790:47  */
  assign n627 = ~rd_multiple;
  /* sd_spi.vhd:790:33  */
  assign n629 = n627 ? 6'b010100 : state;
  /* sd_spi.vhd:787:25  */
  assign n631 = n626 ? 6'b000000 : n629;
  /* sd_spi.vhd:785:17  */
  assign n633 = state == 6'b100000;
  /* sd_spi.vhd:795:17  */
  assign n635 = state == 6'b101001;
  /* sd_spi.vhd:803:52  */
  assign n637 = {32'b01010111000000000000000000000000, wr_erase_count};
  /* sd_spi.vhd:804:25  */
  assign n640 = wr ? 6'b101011 : 6'b101100;
  /* sd_spi.vhd:801:17  */
  assign n642 = state == 6'b101010;
  /* sd_spi.vhd:815:38  */
  assign n644 = card_type == 2'b11;
  /* sd_spi.vhd:816:54  */
  assign n646 = {8'b01011000, address};
  /* sd_spi.vhd:818:63  */
  assign n647 = address[22:0]; // extract
  /* sd_spi.vhd:818:54  */
  assign n649 = {8'b01011000, n647};
  /* sd_spi.vhd:818:77  */
  assign n651 = {n649, 9'b000000000};
  /* sd_spi.vhd:815:25  */
  assign n652 = n644 ? n646 : n651;
  /* sd_spi.vhd:813:17  */
  assign n654 = state == 6'b101011;
  /* sd_spi.vhd:826:38  */
  assign n656 = card_type == 2'b11;
  /* sd_spi.vhd:827:54  */
  assign n658 = {8'b01011001, address};
  /* sd_spi.vhd:829:63  */
  assign n659 = address[22:0]; // extract
  /* sd_spi.vhd:829:54  */
  assign n661 = {8'b01011001, n659};
  /* sd_spi.vhd:829:77  */
  assign n663 = {n661, 9'b000000000};
  /* sd_spi.vhd:826:25  */
  assign n664 = n656 ? n658 : n663;
  /* sd_spi.vhd:824:17  */
  assign n666 = state == 6'b101100;
  /* sd_spi.vhd:837:35  */
  assign n668 = data_in != 8'b00000000;
  /* sd_spi.vhd:837:25  */
  assign n671 = n668 ? 6'b110111 : 6'b101110;
  /* sd_spi.vhd:837:25  */
  assign n673 = n668 ? 1'b1 : error;
  /* sd_spi.vhd:837:25  */
  assign n675 = n668 ? 3'b001 : error_code;
  /* sd_spi.vhd:835:17  */
  assign n677 = state == 6'b101101;
  /* sd_spi.vhd:847:25  */
  assign n680 = multiple ? 8'b11111100 : 8'b11111110;
  /* sd_spi.vhd:845:17  */
  assign n682 = state == 6'b101110;
  /* sd_spi.vhd:855:17  */
  assign n684 = state == 6'b101111;
  /* sd_spi.vhd:863:41  */
  assign n685 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:863:41  */
  assign n687 = n685 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:864:58  */
  assign n688 = out_crc16[15:8]; // extract
  /* sd_spi.vhd:865:56  */
  assign n689 = out_crc16[7:0]; // extract
  /* sd_spi.vhd:868:33  */
  assign n690 = ~wr;
  /* sd_spi.vhd:868:53  */
  assign n691 = ~wr_multiple;
  /* sd_spi.vhd:868:38  */
  assign n692 = n691 & n690;
  /* sd_spi.vhd:871:25  */
  assign n694 = din_latch ? 6'b100001 : state;
  /* sd_spi.vhd:871:25  */
  assign n697 = din_latch ? 6'b110000 : 6'b000000;
  /* sd_spi.vhd:871:25  */
  assign n700 = din_latch ? 1'b1 : 1'b0;
  /* sd_spi.vhd:871:25  */
  assign n702 = din_latch ? 1'b1 : sdin_taken;
  /* sd_spi.vhd:871:25  */
  assign n703 = din_latch ? din : data_out;
  /* sd_spi.vhd:868:25  */
  assign n705 = n692 ? 6'b110101 : n694;
  /* sd_spi.vhd:868:25  */
  assign n707 = n692 ? 6'b000000 : n697;
  /* sd_spi.vhd:868:25  */
  assign n709 = n692 ? 1'b0 : n700;
  /* sd_spi.vhd:868:25  */
  assign n710 = n692 ? sdin_taken : n702;
  /* sd_spi.vhd:868:25  */
  assign n711 = n692 ? data_out : n703;
  /* sd_spi.vhd:863:25  */
  assign n713 = n687 ? 6'b100001 : n705;
  /* sd_spi.vhd:863:25  */
  assign n715 = n687 ? 6'b110001 : n707;
  /* sd_spi.vhd:863:25  */
  assign n717 = n687 ? 1'b1 : n709;
  /* sd_spi.vhd:863:25  */
  assign n718 = n687 ? sdin_taken : n710;
  /* sd_spi.vhd:863:25  */
  assign n719 = n687 ? n689 : crclow;
  /* sd_spi.vhd:863:25  */
  assign n720 = n687 ? n688 : n711;
  /* sd_spi.vhd:861:17  */
  assign n722 = state == 6'b110000;
  /* sd_spi.vhd:878:17  */
  assign n724 = state == 6'b110001;
  /* sd_spi.vhd:884:17  */
  assign n726 = state == 6'b110010;
  /* sd_spi.vhd:892:36  */
  assign n727 = data_in[4]; // extract
  /* sd_spi.vhd:892:40  */
  assign n729 = n727 != 1'b0;
  /* sd_spi.vhd:892:59  */
  assign n730 = data_in[0]; // extract
  /* sd_spi.vhd:892:63  */
  assign n732 = n730 != 1'b1;
  /* sd_spi.vhd:892:48  */
  assign n733 = n729 | n732;
  /* sd_spi.vhd:893:48  */
  assign n734 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:893:48  */
  assign n736 = n734 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:898:74  */
  assign n737 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:898:74  */
  assign n739 = n737 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:898:61  */
  assign n740 = n739[9:0];  // trunc
  /* sd_spi.vhd:893:33  */
  assign n743 = n736 ? 6'b110110 : 6'b100001;
  /* sd_spi.vhd:893:33  */
  assign n745 = n736 ? 1'b1 : error;
  /* sd_spi.vhd:893:33  */
  assign n747 = n736 ? 3'b001 : error_code;
  /* sd_spi.vhd:893:33  */
  assign n748 = n736 ? byte_counter : n740;
  /* sd_spi.vhd:893:33  */
  assign n751 = n736 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:901:38  */
  assign n752 = data_in[3:1]; // extract
  /* sd_spi.vhd:901:51  */
  assign n754 = n752 != 3'b010;
  /* sd_spi.vhd:901:25  */
  assign n757 = n754 ? 6'b110110 : 6'b100001;
  /* sd_spi.vhd:901:25  */
  assign n760 = n754 ? 6'b000000 : 6'b110100;
  /* sd_spi.vhd:901:25  */
  assign n763 = n754 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:901:25  */
  assign n765 = n754 ? 1'b1 : error;
  /* sd_spi.vhd:901:25  */
  assign n767 = n754 ? 3'b011 : error_code;
  /* sd_spi.vhd:901:25  */
  assign n770 = n754 ? 40'bX : 40'b0000000000000000000100001111001111011000;
  /* sd_spi.vhd:901:25  */
  assign n773 = n754 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:892:25  */
  assign n774 = n733 ? n743 : n757;
  /* sd_spi.vhd:892:25  */
  assign n776 = n733 ? 6'b000000 : n760;
  /* sd_spi.vhd:892:25  */
  assign n778 = n733 ? 1'b0 : n763;
  /* sd_spi.vhd:892:25  */
  assign n779 = n733 ? n745 : n765;
  /* sd_spi.vhd:892:25  */
  assign n780 = n733 ? n747 : n767;
  /* sd_spi.vhd:892:25  */
  assign n782 = n733 ? 40'bX : n770;
  /* sd_spi.vhd:892:25  */
  assign n784 = n733 ? 1'b0 : n773;
  /* sd_spi.vhd:892:25  */
  assign n785 = n733 ? n748 : byte_counter;
  /* sd_spi.vhd:892:25  */
  assign n787 = n733 ? n751 : 1'b0;
  /* sd_spi.vhd:890:17  */
  assign n789 = state == 6'b110011;
  /* sd_spi.vhd:916:35  */
  assign n791 = data_in == 8'b00000000;
  /* sd_spi.vhd:917:43  */
  assign n793 = cmd_out == 40'b0000000000000000000000000000000000000000;
  /* sd_spi.vhd:922:91  */
  assign n795 = cmd_out - 40'b0000000000000000000000000000000000000001;
  /* sd_spi.vhd:917:33  */
  assign n798 = n793 ? 6'b110110 : 6'b100001;
  /* sd_spi.vhd:916:25  */
  assign n800 = n815 ? 1'b1 : error;
  /* sd_spi.vhd:916:25  */
  assign n802 = n816 ? 3'b010 : error_code;
  /* sd_spi.vhd:917:33  */
  assign n804 = n793 ? 40'bX : n795;
  /* sd_spi.vhd:917:33  */
  assign n807 = n793 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:928:49  */
  assign n809 = din_latch ? 6'b101110 : state;
  /* sd_spi.vhd:927:41  */
  assign n811 = wr_multiple ? n809 : 6'b110110;
  /* sd_spi.vhd:926:33  */
  assign n813 = multiple ? n811 : 6'b110111;
  /* sd_spi.vhd:916:25  */
  assign n814 = n791 ? n798 : n813;
  /* sd_spi.vhd:916:25  */
  assign n815 = n793 & n791;
  /* sd_spi.vhd:916:25  */
  assign n816 = n793 & n791;
  /* sd_spi.vhd:916:25  */
  assign n818 = n791 ? n804 : 40'bX;
  /* sd_spi.vhd:916:25  */
  assign n820 = n791 ? n807 : 1'b0;
  /* sd_spi.vhd:914:17  */
  assign n822 = state == 6'b110100;
  /* sd_spi.vhd:943:40  */
  assign n823 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:943:40  */
  assign n825 = n823 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:944:58  */
  assign n826 = out_crc16[15:8]; // extract
  /* sd_spi.vhd:945:56  */
  assign n827 = out_crc16[7:0]; // extract
  /* sd_spi.vhd:945:69  */
  assign n829 = n827 ^ 8'b00000001;
  /* sd_spi.vhd:943:25  */
  assign n832 = n825 ? 6'b110001 : 6'b110101;
  /* sd_spi.vhd:943:25  */
  assign n833 = n825 ? n829 : crclow;
  /* sd_spi.vhd:943:25  */
  assign n835 = n825 ? n826 : 8'b00000000;
  /* sd_spi.vhd:941:17  */
  assign n837 = state == 6'b110101;
  /* sd_spi.vhd:956:25  */
  assign n840 = multiple ? 6'b100001 : 6'b110111;
  /* sd_spi.vhd:956:25  */
  assign n843 = multiple ? 6'b110100 : 6'b000000;
  /* sd_spi.vhd:956:25  */
  assign n846 = multiple ? 1'b1 : 1'b0;
  /* sd_spi.vhd:956:25  */
  assign n848 = multiple ? 8'b11111101 : data_out;
  /* sd_spi.vhd:956:25  */
  assign n850 = multiple ? 1'b0 : multiple;
  /* sd_spi.vhd:954:17  */
  assign n852 = state == 6'b110110;
  /* sd_spi.vhd:967:31  */
  assign n853 = ~wr;
  /* sd_spi.vhd:967:51  */
  assign n854 = ~wr_multiple;
  /* sd_spi.vhd:967:36  */
  assign n855 = n854 & n853;
  /* sd_spi.vhd:967:25  */
  assign n857 = n855 ? 6'b010100 : state;
  /* sd_spi.vhd:965:17  */
  assign n859 = state == 6'b110111;
  /* sd_spi.vhd:985:38  */
  assign n861 = slow_clock == 1'b0;
  /* sd_spi.vhd:985:61  */
  assign n862 = {25'b0, clock_divider};  //  uext
  /* sd_spi.vhd:985:61  */
  assign n864 = n862 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:985:45  */
  assign n865 = n861 | n864;
  /* sd_spi.vhd:989:49  */
  assign n866 = crc7[5:3]; // extract
  /* sd_spi.vhd:989:69  */
  assign n867 = crc7[2]; // extract
  /* sd_spi.vhd:989:81  */
  assign n868 = crc7[6]; // extract
  /* sd_spi.vhd:989:73  */
  assign n869 = n867 ^ n868;
  /* sd_spi.vhd:989:97  */
  assign n870 = data_out[7]; // extract
  /* sd_spi.vhd:989:85  */
  assign n871 = n869 ^ n870;
  /* sd_spi.vhd:989:62  */
  assign n872 = {n866, n871};
  /* sd_spi.vhd:989:108  */
  assign n873 = crc7[1:0]; // extract
  /* sd_spi.vhd:989:102  */
  assign n874 = {n872, n873};
  /* sd_spi.vhd:989:128  */
  assign n875 = crc7[6]; // extract
  /* sd_spi.vhd:989:144  */
  assign n876 = data_out[7]; // extract
  /* sd_spi.vhd:989:132  */
  assign n877 = n875 ^ n876;
  /* sd_spi.vhd:989:121  */
  assign n878 = {n874, n877};
  /* sd_spi.vhd:990:59  */
  assign n879 = out_crc16[14:12]; // extract
  /* sd_spi.vhd:990:85  */
  assign n880 = data_out[7]; // extract
  /* sd_spi.vhd:990:102  */
  assign n881 = out_crc16[15]; // extract
  /* sd_spi.vhd:990:89  */
  assign n882 = n880 ^ n881;
  /* sd_spi.vhd:990:120  */
  assign n883 = out_crc16[11]; // extract
  /* sd_spi.vhd:990:107  */
  assign n884 = n882 ^ n883;
  /* sd_spi.vhd:990:74  */
  assign n885 = {n879, n884};
  /* sd_spi.vhd:990:137  */
  assign n886 = out_crc16[10:5]; // extract
  /* sd_spi.vhd:990:126  */
  assign n887 = {n885, n886};
  /* sd_spi.vhd:991:42  */
  assign n888 = data_out[7]; // extract
  /* sd_spi.vhd:991:59  */
  assign n889 = out_crc16[15]; // extract
  /* sd_spi.vhd:991:46  */
  assign n890 = n888 ^ n889;
  /* sd_spi.vhd:991:77  */
  assign n891 = out_crc16[4]; // extract
  /* sd_spi.vhd:991:64  */
  assign n892 = n890 ^ n891;
  /* sd_spi.vhd:990:151  */
  assign n893 = {n887, n892};
  /* sd_spi.vhd:991:93  */
  assign n894 = out_crc16[3:0]; // extract
  /* sd_spi.vhd:991:82  */
  assign n895 = {n893, n894};
  /* sd_spi.vhd:991:117  */
  assign n896 = data_out[7]; // extract
  /* sd_spi.vhd:991:134  */
  assign n897 = out_crc16[15]; // extract
  /* sd_spi.vhd:991:121  */
  assign n898 = n896 ^ n897;
  /* sd_spi.vhd:991:106  */
  assign n899 = {n895, n898};
  /* sd_spi.vhd:993:55  */
  assign n900 = data_in[6:0]; // extract
  /* sd_spi.vhd:993:68  */
  assign n901 = {n900, miso};
  /* sd_spi.vhd:995:57  */
  assign n902 = in_crc16[14:12]; // extract
  /* sd_spi.vhd:995:92  */
  assign n903 = in_crc16[15]; // extract
  /* sd_spi.vhd:995:80  */
  assign n904 = miso ^ n903;
  /* sd_spi.vhd:995:109  */
  assign n905 = in_crc16[11]; // extract
  /* sd_spi.vhd:995:97  */
  assign n906 = n904 ^ n905;
  /* sd_spi.vhd:995:72  */
  assign n907 = {n902, n906};
  /* sd_spi.vhd:995:125  */
  assign n908 = in_crc16[10:5]; // extract
  /* sd_spi.vhd:995:115  */
  assign n909 = {n907, n908};
  /* sd_spi.vhd:996:59  */
  assign n910 = in_crc16[15]; // extract
  /* sd_spi.vhd:996:47  */
  assign n911 = miso ^ n910;
  /* sd_spi.vhd:996:76  */
  assign n912 = in_crc16[4]; // extract
  /* sd_spi.vhd:996:64  */
  assign n913 = n911 ^ n912;
  /* sd_spi.vhd:995:139  */
  assign n914 = {n909, n913};
  /* sd_spi.vhd:996:91  */
  assign n915 = in_crc16[3:0]; // extract
  /* sd_spi.vhd:996:81  */
  assign n916 = {n914, n915};
  /* sd_spi.vhd:996:124  */
  assign n917 = in_crc16[15]; // extract
  /* sd_spi.vhd:996:112  */
  assign n918 = miso ^ n917;
  /* sd_spi.vhd:996:104  */
  assign n919 = {n916, n918};
  /* sd_spi.vhd:999:68  */
  assign n920 = {25'b0, clock_divider};  //  uext
  /* sd_spi.vhd:999:68  */
  assign n922 = n920 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:999:54  */
  assign n923 = n922[6:0];  // trunc
  /* sd_spi.vhd:985:25  */
  assign n925 = n865 ? 6'b100010 : state;
  /* sd_spi.vhd:985:25  */
  assign n928 = n865 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:985:25  */
  assign n929 = n865 ? n901 : data_in;
  /* sd_spi.vhd:985:25  */
  assign n930 = n865 ? n878 : crc7;
  /* sd_spi.vhd:985:25  */
  assign n931 = n865 ? n919 : in_crc16;
  /* sd_spi.vhd:985:25  */
  assign n932 = n865 ? n899 : out_crc16;
  /* sd_spi.vhd:985:25  */
  assign n934 = n865 ? 7'b1000000 : n923;
  /* sd_spi.vhd:971:17  */
  assign n936 = state == 6'b100001;
  /* sd_spi.vhd:1003:38  */
  assign n938 = slow_clock == 1'b0;
  /* sd_spi.vhd:1003:61  */
  assign n939 = {25'b0, clock_divider};  //  uext
  /* sd_spi.vhd:1003:61  */
  assign n941 = n939 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:1003:45  */
  assign n942 = n938 | n941;
  /* sd_spi.vhd:1005:49  */
  assign n943 = {24'b0, bit_counter};  //  uext
  /* sd_spi.vhd:1005:49  */
  assign n945 = n943 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:1008:60  */
  assign n946 = rd | rd_multiple;
  /* sd_spi.vhd:1009:67  */
  assign n947 = ~sdavail;
  /* sd_spi.vhd:1009:86  */
  assign n948 = ~dout_taken;
  /* sd_spi.vhd:1009:72  */
  assign n949 = n948 & n947;
  /* sd_spi.vhd:1013:98  */
  assign n950 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1013:98  */
  assign n952 = n950 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1013:85  */
  assign n953 = n952[9:0];  // trunc
  /* sd_spi.vhd:1016:80  */
  assign n954 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1016:80  */
  assign n956 = n954 == 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1016:65  */
  assign n959 = n956 ? 6'b011100 : 6'b000000;
  /* sd_spi.vhd:1016:65  */
  assign n962 = n956 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:1009:57  */
  assign n964 = n974 ? 1'b0 : transfer_data_out;
  /* sd_spi.vhd:1009:57  */
  assign n966 = n949 ? 6'b100001 : state;
  /* sd_spi.vhd:1009:57  */
  assign n968 = n949 ? n959 : 6'b000000;
  /* sd_spi.vhd:1009:57  */
  assign n970 = n949 ? n962 : 1'b0;
  /* sd_spi.vhd:1009:57  */
  assign n973 = n949 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:1009:57  */
  assign n974 = n956 & n949;
  /* sd_spi.vhd:1009:57  */
  assign n975 = n949 ? n953 : byte_counter;
  /* sd_spi.vhd:1009:57  */
  assign n978 = n949 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:1009:57  */
  assign n980 = n949 ? 8'b00000111 : bit_counter;
  /* sd_spi.vhd:1025:90  */
  assign n981 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1025:90  */
  assign n983 = n981 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1025:77  */
  assign n984 = n983[9:0];  // trunc
  /* sd_spi.vhd:1028:72  */
  assign n985 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1028:72  */
  assign n987 = n985 == 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1028:57  */
  assign n990 = n987 ? 6'b011100 : 6'b000000;
  /* sd_spi.vhd:1028:57  */
  assign n993 = n987 ? 1'b1 : 1'b0;
  /* sd_spi.vhd:1028:57  */
  assign n995 = n987 ? 1'b0 : transfer_data_out;
  /* sd_spi.vhd:1008:49  */
  assign n997 = n946 ? n966 : 6'b100001;
  /* sd_spi.vhd:1008:49  */
  assign n998 = n946 ? n968 : n990;
  /* sd_spi.vhd:1008:49  */
  assign n999 = n946 ? n970 : n993;
  /* sd_spi.vhd:1008:49  */
  assign n1001 = n946 ? n973 : 1'b0;
  /* sd_spi.vhd:1008:49  */
  assign n1002 = n946 ? n964 : n995;
  /* sd_spi.vhd:1008:49  */
  assign n1003 = n946 ? n975 : n984;
  /* sd_spi.vhd:1008:49  */
  assign n1005 = n946 ? n978 : 1'b1;
  /* sd_spi.vhd:1008:49  */
  assign n1007 = n946 ? n980 : 8'b00000111;
  /* sd_spi.vhd:1038:82  */
  assign n1008 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1038:82  */
  assign n1010 = n1008 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1038:69  */
  assign n1011 = n1010[9:0];  // trunc
  /* sd_spi.vhd:1007:41  */
  assign n1012 = transfer_data_out ? n997 : sr_return_state;
  /* sd_spi.vhd:1007:41  */
  assign n1014 = transfer_data_out ? n998 : 6'b000000;
  /* sd_spi.vhd:1007:41  */
  assign n1016 = transfer_data_out ? n999 : 1'b0;
  /* sd_spi.vhd:1007:41  */
  assign n1018 = transfer_data_out ? n1001 : 1'b0;
  /* sd_spi.vhd:1003:25  */
  assign n1019 = n1060 ? n1002 : transfer_data_out;
  /* sd_spi.vhd:1007:41  */
  assign n1020 = transfer_data_out ? n1003 : n1011;
  /* sd_spi.vhd:1007:41  */
  assign n1022 = transfer_data_out ? n1005 : 1'b1;
  /* sd_spi.vhd:1007:41  */
  assign n1024 = transfer_data_out ? n1007 : 8'b00000111;
  /* sd_spi.vhd:1041:72  */
  assign n1025 = {24'b0, bit_counter};  //  uext
  /* sd_spi.vhd:1041:72  */
  assign n1027 = n1025 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1041:60  */
  assign n1028 = n1027[7:0];  // trunc
  /* sd_spi.vhd:1042:65  */
  assign n1029 = data_out[6:0]; // extract
  /* sd_spi.vhd:1042:78  */
  assign n1031 = {n1029, 1'b1};
  /* sd_spi.vhd:1005:33  */
  assign n1033 = n945 ? n1012 : 6'b100001;
  /* sd_spi.vhd:1005:33  */
  assign n1035 = n945 ? n1014 : 6'b000000;
  /* sd_spi.vhd:1005:33  */
  assign n1037 = n945 ? n1016 : 1'b0;
  /* sd_spi.vhd:1005:33  */
  assign n1039 = n945 ? n1018 : 1'b0;
  /* sd_spi.vhd:1005:33  */
  assign n1040 = transfer_data_out & n945;
  /* sd_spi.vhd:1005:33  */
  assign n1041 = n945 ? data_out : n1031;
  /* sd_spi.vhd:1003:25  */
  assign n1042 = n1062 ? n1020 : byte_counter;
  /* sd_spi.vhd:1005:33  */
  assign n1044 = n945 ? n1022 : 1'b0;
  /* sd_spi.vhd:1005:33  */
  assign n1045 = n945 ? n1024 : n1028;
  /* sd_spi.vhd:1047:68  */
  assign n1046 = {25'b0, clock_divider};  //  uext
  /* sd_spi.vhd:1047:68  */
  assign n1048 = n1046 - 32'b00000000000000000000000000000001;
  /* sd_spi.vhd:1047:54  */
  assign n1049 = n1048[6:0];  // trunc
  /* sd_spi.vhd:1003:25  */
  assign n1050 = n942 ? n1033 : state;
  /* sd_spi.vhd:1003:25  */
  assign n1052 = n942 ? n1035 : 6'b000000;
  /* sd_spi.vhd:1003:25  */
  assign n1054 = n942 ? n1037 : 1'b0;
  /* sd_spi.vhd:1003:25  */
  assign n1057 = n942 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:1003:25  */
  assign n1059 = n942 ? n1039 : 1'b0;
  /* sd_spi.vhd:1003:25  */
  assign n1060 = n1040 & n942;
  /* sd_spi.vhd:1003:25  */
  assign n1061 = n942 ? n1041 : data_out;
  /* sd_spi.vhd:1003:25  */
  assign n1062 = n945 & n942;
  /* sd_spi.vhd:1003:25  */
  assign n1064 = n942 ? n1044 : 1'b0;
  /* sd_spi.vhd:1003:25  */
  assign n1065 = n942 ? n1045 : bit_counter;
  /* sd_spi.vhd:1003:25  */
  assign n1067 = n942 ? 7'b1000000 : n1049;
  /* sd_spi.vhd:1002:17  */
  assign n1069 = state == 6'b100010;
  /* sd_spi.vhd:1050:17  */
  assign n1071 = state == 6'b100011;
  /* sd_spi.vhd:1057:17  */
  assign n1073 = state == 6'b100100;
  /* sd_spi.vhd:1065:40  */
  assign n1074 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1065:40  */
  assign n1076 = n1074 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:1068:56  */
  assign n1077 = cmd_out[39:32]; // extract
  /* sd_spi.vhd:1069:55  */
  assign n1078 = cmd_out[31:0]; // extract
  /* sd_spi.vhd:1069:69  */
  assign n1080 = {n1078, 8'b11111111};
  /* sd_spi.vhd:1065:25  */
  assign n1083 = n1076 ? 6'b100110 : 6'b100001;
  /* sd_spi.vhd:1065:25  */
  assign n1086 = n1076 ? 6'b000000 : 6'b100101;
  /* sd_spi.vhd:1065:25  */
  assign n1089 = n1076 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:1065:25  */
  assign n1091 = n1076 ? 40'bX : n1080;
  /* sd_spi.vhd:1065:25  */
  assign n1094 = n1076 ? 1'b0 : 1'b1;
  /* sd_spi.vhd:1065:25  */
  assign n1095 = n1076 ? data_out : n1077;
  /* sd_spi.vhd:1063:17  */
  assign n1097 = state == 6'b100101;
  /* sd_spi.vhd:1076:46  */
  assign n1099 = {crc7, 1'b1};
  /* sd_spi.vhd:1074:17  */
  assign n1101 = state == 6'b100110;
  /* sd_spi.vhd:1080:17  */
  assign n1103 = state == 6'b100111;
  /* sd_spi.vhd:1092:38  */
  assign n1104 = data_in[7]; // extract
  /* sd_spi.vhd:1092:47  */
  assign n1105 = ~n1104;
  /* sd_spi.vhd:1095:48  */
  assign n1106 = {22'b0, byte_counter};  //  uext
  /* sd_spi.vhd:1095:48  */
  assign n1108 = n1106 == 32'b00000000000000000000000000000000;
  /* sd_spi.vhd:1095:33  */
  assign n1110 = n1108 ? state : 6'b100001;
  /* sd_spi.vhd:1095:33  */
  assign n1112 = n1108 ? 2'b00 : card_type;
  /* sd_spi.vhd:1095:33  */
  assign n1114 = n1108 ? 1'b1 : error;
  /* sd_spi.vhd:1095:33  */
  assign n1116 = n1108 ? 3'b111 : error_code;
  /* sd_spi.vhd:1092:25  */
  assign n1117 = n1105 ? return_state : n1110;
  /* sd_spi.vhd:1092:25  */
  assign n1118 = n1105 ? card_type : n1112;
  /* sd_spi.vhd:1092:25  */
  assign n1119 = n1105 ? error : n1114;
  /* sd_spi.vhd:1092:25  */
  assign n1120 = n1105 ? error_code : n1116;
  /* sd_spi.vhd:1088:25  */
  assign n1122 = skipfirstr1byte ? 6'b100001 : n1117;
  /* sd_spi.vhd:1088:25  */
  assign n1123 = skipfirstr1byte ? card_type : n1118;
  /* sd_spi.vhd:1088:25  */
  assign n1124 = skipfirstr1byte ? error : n1119;
  /* sd_spi.vhd:1088:25  */
  assign n1125 = skipfirstr1byte ? error_code : n1120;
  /* sd_spi.vhd:1088:25  */
  assign n1127 = skipfirstr1byte ? 1'b0 : skipfirstr1byte;
  /* sd_spi.vhd:1086:17  */
  assign n1129 = state == 6'b101000;
  /* sd_spi.vhd:423:17  */
  assign n1130 = {n1129, n1103, n1101, n1097, n1073, n1071, n1069, n936, n859, n852, n837, n822, n789, n726, n724, n722, n684, n682, n677, n666, n654, n642, n635, n633, n624, n622, n613, n589, n587, n571, n547, n501, n484, n472, n460, n359, n357, n338, n336, n334, n332, n327, n309, n307, n296, n289, n287, n280, n273, n271, n269, n254, n229, n227, n219, n215};
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1162 = n1122;
      56'b01000000000000000000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00100000000000000000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00010000000000000000000000000000000000000000000000000000: n1162 = n1083;
      56'b00001000000000000000000000000000000000000000000000000000: n1162 = 6'b100101;
      56'b00000100000000000000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00000010000000000000000000000000000000000000000000000000: n1162 = n1050;
      56'b00000001000000000000000000000000000000000000000000000000: n1162 = n925;
      56'b00000000100000000000000000000000000000000000000000000000: n1162 = n857;
      56'b00000000010000000000000000000000000000000000000000000000: n1162 = n840;
      56'b00000000001000000000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00000000000100000000000000000000000000000000000000000000: n1162 = n814;
      56'b00000000000010000000000000000000000000000000000000000000: n1162 = n774;
      56'b00000000000001000000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00000000000000100000000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00000000000000010000000000000000000000000000000000000000: n1162 = n713;
      56'b00000000000000001000000000000000000000000000000000000000: n1162 = 6'b110000;
      56'b00000000000000000100000000000000000000000000000000000000: n1162 = 6'b100001;
      56'b00000000000000000010000000000000000000000000000000000000: n1162 = n671;
      56'b00000000000000000001000000000000000000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000100000000000000000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000010000000000000000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000001000000000000000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000100000000000000000000000000000000: n1162 = n631;
      56'b00000000000000000000000010000000000000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000001000000000000000000000000000000: n1162 = n620;
      56'b00000000000000000000000000100000000000000000000000000000: n1162 = n603;
      56'b00000000000000000000000000010000000000000000000000000000: n1162 = 6'b100001;
      56'b00000000000000000000000000001000000000000000000000000000: n1162 = n580;
      56'b00000000000000000000000000000100000000000000000000000000: n1162 = n564;
      56'b00000000000000000000000000000010000000000000000000000000: n1162 = n535;
      56'b00000000000000000000000000000001000000000000000000000000: n1162 = n489;
      56'b00000000000000000000000000000000100000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000010000000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000001000000000000000000000: n1162 = n447;
      56'b00000000000000000000000000000000000100000000000000000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000010000000000000000000: n1162 = n351;
      56'b00000000000000000000000000000000000001000000000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000000000100000000000000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000010000000000000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000001000000000000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000000100000000000000: n1162 = n313;
      56'b00000000000000000000000000000000000000000010000000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000000000000001000000000000: n1162 = n305;
      56'b00000000000000000000000000000000000000000000100000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000000000000000010000000000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000000000000000001000000000: n1162 = n285;
      56'b00000000000000000000000000000000000000000000000100000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000000000000010000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000000000000001000000: n1162 = 6'b100001;
      56'b00000000000000000000000000000000000000000000000000100000: n1162 = n258;
      56'b00000000000000000000000000000000000000000000000000010000: n1162 = n234;
      56'b00000000000000000000000000000000000000000000000000001000: n1162 = 6'b100011;
      56'b00000000000000000000000000000000000000000000000000000100: n1162 = n225;
      56'b00000000000000000000000000000000000000000000000000000010: n1162 = n217;
      56'b00000000000000000000000000000000000000000000000000000001: n1162 = 6'b000001;
      default: n1162 = 6'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b01000000000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00100000000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00010000000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00001000000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000100000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000010000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000001000000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000100000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000010000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000001000000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000100000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000010000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000001000000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000100000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000010000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000001000000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000100000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000010000000000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000001000000000000000000000000000000000000: n1176 = 6'b101101;
      56'b00000000000000000000100000000000000000000000000000000000: n1176 = 6'b101101;
      56'b00000000000000000000010000000000000000000000000000000000: n1176 = n640;
      56'b00000000000000000000001000000000000000000000000000000000: n1176 = 6'b101010;
      56'b00000000000000000000000100000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000010000000000000000000000000000000: n1176 = 6'b100000;
      56'b00000000000000000000000001000000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000100000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000010000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000001000000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000100000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000010000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000001000000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000100000000000000000000000: n1176 = 6'b011000;
      56'b00000000000000000000000000000000010000000000000000000000: n1176 = 6'b011000;
      56'b00000000000000000000000000000000001000000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000100000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000010000000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000001000000000000000000: n1176 = 6'b010011;
      56'b00000000000000000000000000000000000000100000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000010000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000001000000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000100000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000010000000000000: n1176 = 6'b001110;
      56'b00000000000000000000000000000000000000000001000000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000100000000000: n1176 = 6'b001100;
      56'b00000000000000000000000000000000000000000000010000000000: n1176 = 6'b001011;
      56'b00000000000000000000000000000000000000000000001000000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000100000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000010000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000001000000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000100000: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000010000: n1176 = n237;
      56'b00000000000000000000000000000000000000000000000000001000: n1176 = 6'b000100;
      56'b00000000000000000000000000000000000000000000000000000100: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000000010: n1176 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000000001: n1176 = 6'b000000;
      default: n1176 = 6'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b01000000000000000000000000000000000000000000000000000000: n1195 = 6'b101000;
      56'b00100000000000000000000000000000000000000000000000000000: n1195 = 6'b100111;
      56'b00010000000000000000000000000000000000000000000000000000: n1195 = n1086;
      56'b00001000000000000000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000100000000000000000000000000000000000000000000000000: n1195 = 6'b100100;
      56'b00000010000000000000000000000000000000000000000000000000: n1195 = n1052;
      56'b00000001000000000000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000100000000000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000010000000000000000000000000000000000000000000000: n1195 = n843;
      56'b00000000001000000000000000000000000000000000000000000000: n1195 = n832;
      56'b00000000000100000000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000010000000000000000000000000000000000000000000: n1195 = n776;
      56'b00000000000001000000000000000000000000000000000000000000: n1195 = 6'b110011;
      56'b00000000000000100000000000000000000000000000000000000000: n1195 = 6'b110010;
      56'b00000000000000010000000000000000000000000000000000000000: n1195 = n715;
      56'b00000000000000001000000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000100000000000000000000000000000000000000: n1195 = 6'b101111;
      56'b00000000000000000010000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000001000000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000100000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000010000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000001000000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000100000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000010000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000001000000000000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000100000000000000000000000000000: n1195 = n605;
      56'b00000000000000000000000000010000000000000000000000000000: n1195 = 6'b011101;
      56'b00000000000000000000000000001000000000000000000000000000: n1195 = n582;
      56'b00000000000000000000000000000100000000000000000000000000: n1195 = n566;
      56'b00000000000000000000000000000010000000000000000000000000: n1195 = n537;
      56'b00000000000000000000000000000001000000000000000000000000: n1195 = n492;
      56'b00000000000000000000000000000000100000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000010000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000001000000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000100000000000000000000: n1195 = 6'b010101;
      56'b00000000000000000000000000000000000010000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000001000000000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000100000000000000000: n1195 = 6'b010010;
      56'b00000000000000000000000000000000000000010000000000000000: n1195 = 6'b010001;
      56'b00000000000000000000000000000000000000001000000000000000: n1195 = 6'b010000;
      56'b00000000000000000000000000000000000000000100000000000000: n1195 = n316;
      56'b00000000000000000000000000000000000000000010000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000001000000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000100000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000010000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000001000000000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000100000000: n1195 = 6'b001001;
      56'b00000000000000000000000000000000000000000000000010000000: n1195 = 6'b001000;
      56'b00000000000000000000000000000000000000000000000001000000: n1195 = 6'b000111;
      56'b00000000000000000000000000000000000000000000000000100000: n1195 = n261;
      56'b00000000000000000000000000000000000000000000000000010000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000001000: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000000100: n1195 = 6'b000000;
      56'b00000000000000000000000000000000000000000000000000000010: n1195 = 6'b000010;
      56'b00000000000000000000000000000000000000000000000000000001: n1195 = 6'b000000;
      default: n1195 = 6'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00100000000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00001000000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000001000000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000001000000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000100000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000100000000000000000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000010000000000000000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000001000000000000000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000000100000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000000001000000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000001000000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000010000000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000001000000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000000000100000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000000000000001000000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000000000000000010000000000: n1211 = 1'b1;
      56'b00000000000000000000000000000000000000000000001000000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1211 = n240;
      56'b00000000000000000000000000000000000000000000000000001000: n1211 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000100: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1211 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1211 = 1'b0;
      default: n1211 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00100000000000000000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00010000000000000000000000000000000000000000000000000000: n1231 = n1089;
      56'b00001000000000000000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00000010000000000000000000000000000000000000000000000000: n1231 = n1054;
      56'b00000001000000000000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1231 = n846;
      56'b00000000001000000000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00000000000100000000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1231 = n778;
      56'b00000000000001000000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00000000000000100000000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00000000000000010000000000000000000000000000000000000000: n1231 = n717;
      56'b00000000000000001000000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1231 = 1'b1;
      56'b00000000000000000010000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000100000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000010000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000001000000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000100000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000001000000000000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1231 = n607;
      56'b00000000000000000000000000010000000000000000000000000000: n1231 = 1'b1;
      56'b00000000000000000000000000001000000000000000000000000000: n1231 = n585;
      56'b00000000000000000000000000000100000000000000000000000000: n1231 = n568;
      56'b00000000000000000000000000000010000000000000000000000000: n1231 = n539;
      56'b00000000000000000000000000000001000000000000000000000000: n1231 = n495;
      56'b00000000000000000000000000000000100000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000010000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000001000000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000010000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000100000000000000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000010000000000000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000001000000000000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000000100000000000000: n1231 = n319;
      56'b00000000000000000000000000000000000000000010000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000001000000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000010000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000001000000000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000000000000010000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000000000000001000000: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000100000: n1231 = n264;
      56'b00000000000000000000000000000000000000000000000000010000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000001000: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000100: n1231 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1231 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000001: n1231 = 1'b0;
      default: n1231 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00100000000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00001000000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1235 = n1057;
      56'b00000001000000000000000000000000000000000000000000000000: n1235 = n928;
      56'b00000000100000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000001000000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000100000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000100000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000010000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000001000000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000100000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000001000000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000001000000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000010000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000001000000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000100000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000001000000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000010000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000001000000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000001000: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000100: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1235 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1235 = 1'b0;
      default: n1235 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b01000000000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00100000000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00010000000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00001000000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000100000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000010000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000001000000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000100000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000010000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000001000000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000100000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000010000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000001000000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000100000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000010000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000001000000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000100000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000010000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000001000000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000100000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000010000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000001000000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000100000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000010000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000001000000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000100000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000010000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000001000000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000100000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000010000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000001000000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000100000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000010000000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000001000000000000000000000: n1240 = n448;
      56'b00000000000000000000000000000000000100000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000010000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000001000000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000100000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000010000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000001000000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000100000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000010000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000001000000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000100000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000010000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000001000000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000100000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000010000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000001000000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000000100000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000000010000: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000000001000: n1240 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000100: n1240 = scs;
      56'b00000000000000000000000000000000000000000000000000000010: n1240 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000001: n1240 = scs;
      default: n1240 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00100000000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00001000000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1243 = n1059;
      56'b00000001000000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000001000000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000100000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000100000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000010000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000001000000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000100000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000001000000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000001000000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000010000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000001000000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000100000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000001000000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000010000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000001000000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000001000: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000100: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1243 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1243 = 1'b0;
      default: n1243 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b01000000000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00100000000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00010000000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00001000000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000100000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000010000000000000000000000000000000000000000000000000: n1250 = n1019;
      56'b00000001000000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000100000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000010000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000001000000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000100000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000010000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000001000000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000100000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000010000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000001000000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000100000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000010000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000001000000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000100000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000010000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000001000000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000100000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000010000000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000001000000000000000000000000000000: n1250 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000010000000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000001000000000000000000000000000: n1250 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1250 = n569;
      56'b00000000000000000000000000000010000000000000000000000000: n1250 = n540;
      56'b00000000000000000000000000000001000000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000100000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000010000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000001000000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000100000000000000000000: n1250 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000001000000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000100000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000010000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000001000000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000100000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000010000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000001000000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000100000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000010000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000001000000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000100000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000010000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000001000000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000000100000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000000010000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000000001000: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000000000100: n1250 = transfer_data_out;
      56'b00000000000000000000000000000000000000000000000000000010: n1250 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1250 = transfer_data_out;
      default: n1250 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1253 = n1123;
      56'b01000000000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00100000000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00010000000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00001000000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000100000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000010000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000001000000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000100000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000010000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000001000000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000100000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000010000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000001000000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000100000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000010000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000001000000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000100000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000010000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000001000000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000100000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000010000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000001000000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000100000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000010000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000001000000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000100000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000010000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000001000000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000100000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000010000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000001000000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000100000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000010000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000001000000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000100000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000010000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000001000000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000100000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000010000000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000001000000000000000: n1253 = n330;
      56'b00000000000000000000000000000000000000000100000000000000: n1253 = n321;
      56'b00000000000000000000000000000000000000000010000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000001000000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000100000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000010000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000001000000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000100000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000010000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000001000000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000000100000: n1253 = n267;
      56'b00000000000000000000000000000000000000000000000000010000: n1253 = n242;
      56'b00000000000000000000000000000000000000000000000000001000: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000000000100: n1253 = card_type;
      56'b00000000000000000000000000000000000000000000000000000010: n1253 = 2'b00;
      56'b00000000000000000000000000000000000000000000000000000001: n1253 = card_type;
      default: n1253 = 2'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1256 = n1124;
      56'b01000000000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00100000000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00010000000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00001000000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000100000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000010000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000001000000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000000100000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000000010000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000000001000000000000000000000000000000000000000000000: n1256 = error;
      56'b00000000000100000000000000000000000000000000000000000000: n1256 = n800;
      56'b00000000000010000000000000000000000000000000000000000000: n1256 = n779;
      56'b00000000000001000000000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000100000000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000010000000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000001000000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000100000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000010000000000000000000000000000000000000: n1256 = n673;
      56'b00000000000000000001000000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000100000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000010000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000001000000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000100000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000010000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000001000000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000000100000000000000000000000000000: n1256 = n609;
      56'b00000000000000000000000000010000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000000001000000000000000000000000000: n1256 = error;
      56'b00000000000000000000000000000100000000000000000000000000: n1256 = error;
      56'b00000000000000000000000000000010000000000000000000000000: n1256 = n541;
      56'b00000000000000000000000000000001000000000000000000000000: n1256 = n497;
      56'b00000000000000000000000000000000100000000000000000000000: n1256 = error;
      56'b00000000000000000000000000000000010000000000000000000000: n1256 = error;
      56'b00000000000000000000000000000000001000000000000000000000: n1256 = n449;
      56'b00000000000000000000000000000000000100000000000000000000: n1256 = error;
      56'b00000000000000000000000000000000000010000000000000000000: n1256 = n353;
      56'b00000000000000000000000000000000000001000000000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000100000000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000010000000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000001000000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000100000000000000: n1256 = n323;
      56'b00000000000000000000000000000000000000000010000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000001000000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000100000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000010000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000001000000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000100000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000010000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000001000000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000000100000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000000010000: n1256 = n244;
      56'b00000000000000000000000000000000000000000000000000001000: n1256 = error;
      56'b00000000000000000000000000000000000000000000000000000100: n1256 = error;
      56'b00000000000000000000000000000000000000000000000000000010: n1256 = error;
      56'b00000000000000000000000000000000000000000000000000000001: n1256 = 1'b1;
      default: n1256 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1259 = n1125;
      56'b01000000000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00100000000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00010000000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00001000000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000100000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000010000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000001000000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000100000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000010000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000001000000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000100000000000000000000000000000000000000000000: n1259 = n802;
      56'b00000000000010000000000000000000000000000000000000000000: n1259 = n780;
      56'b00000000000001000000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000100000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000010000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000001000000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000100000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000010000000000000000000000000000000000000: n1259 = n675;
      56'b00000000000000000001000000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000100000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000010000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000001000000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000100000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000010000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000001000000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000100000000000000000000000000000: n1259 = n611;
      56'b00000000000000000000000000010000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000001000000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000100000000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000010000000000000000000000000: n1259 = n542;
      56'b00000000000000000000000000000001000000000000000000000000: n1259 = n499;
      56'b00000000000000000000000000000000100000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000010000000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000001000000000000000000000: n1259 = n450;
      56'b00000000000000000000000000000000000100000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000010000000000000000000: n1259 = n355;
      56'b00000000000000000000000000000000000001000000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000100000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000010000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000001000000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000100000000000000: n1259 = n325;
      56'b00000000000000000000000000000000000000000010000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000001000000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000100000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000010000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000001000000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000100000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000010000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000001000000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000000100000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000000010000: n1259 = n246;
      56'b00000000000000000000000000000000000000000000000000001000: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000000000100: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000000000010: n1259 = error_code;
      56'b00000000000000000000000000000000000000000000000000000001: n1259 = 3'b111;
      default: n1259 = 3'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b01000000000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00100000000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00010000000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00001000000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000100000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000010000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000001000000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000100000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000010000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000001000000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000100000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000010000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000001000000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000100000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000010000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000001000000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000100000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000010000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000001000000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000100000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000010000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000001000000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000100000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000010000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000001000000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000100000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000010000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000001000000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000100000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000010000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000001000000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000100000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000010000000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000001000000000000000000000: n1262 = n452;
      56'b00000000000000000000000000000000000100000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000010000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000001000000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000100000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000010000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000001000000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000100000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000010000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000001000000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000100000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000010000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000001000000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000100000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000010000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000001000000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000100000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000010000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000001000: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000100: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000010: n1262 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000001: n1262 = 1'b1;
      default: n1262 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b01000000000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00100000000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00010000000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00001000000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000100000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000010000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000001000000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000100000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000010000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000001000000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000100000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000010000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000001000000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000100000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000010000000000000000000000000000000000000000: n1265 = n718;
      56'b00000000000000001000000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000100000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000010000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000001000000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000100000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000010000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000001000000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000100000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000010000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000001000000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000100000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000010000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000001000000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000100000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000010000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000001000000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000100000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000010000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000001000000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000100000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000010000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000001000000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000100000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000010000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000001000000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000100000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000010000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000001000000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000100000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000010000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000001000000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000100000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000010000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000001000000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000100000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000010000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000001000: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000000100: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000000010: n1265 = sdin_taken;
      56'b00000000000000000000000000000000000000000000000000000001: n1265 = sdin_taken;
      default: n1265 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b01000000000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00100000000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00010000000000000000000000000000000000000000000000000000: n1274 = n1091;
      56'b00001000000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000100000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000010000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000001000000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000100000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000010000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000001000000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000100000000000000000000000000000000000000000000: n1274 = n818;
      56'b00000000000010000000000000000000000000000000000000000000: n1274 = n782;
      56'b00000000000001000000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000100000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000010000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000001000000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000100000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000010000000000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000001000000000000000000000000000000000000: n1274 = n664;
      56'b00000000000000000000100000000000000000000000000000000000: n1274 = n652;
      56'b00000000000000000000010000000000000000000000000000000000: n1274 = n637;
      56'b00000000000000000000001000000000000000000000000000000000: n1274 = 40'b0111011100000000000000000000000000000000;
      56'b00000000000000000000000100000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000010000000000000000000000000000000: n1274 = 40'b0100110000000000000000000000000000000000;
      56'b00000000000000000000000001000000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000100000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000010000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000001000000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000100000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000010000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000001000000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000100000000000000000000000: n1274 = n482;
      56'b00000000000000000000000000000000010000000000000000000000: n1274 = n470;
      56'b00000000000000000000000000000000001000000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000100000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000010000000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000001000000000000000000: n1274 = 40'b0111101100000000000000000000000000000001;
      56'b00000000000000000000000000000000000000100000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000010000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000001000000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000100000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000010000000000000: n1274 = 40'b0111101000000000000000000000000000000000;
      56'b00000000000000000000000000000000000000000001000000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000100000000000: n1274 = n294;
      56'b00000000000000000000000000000000000000000000010000000000: n1274 = 40'b0111011100000000000000000000000000000000;
      56'b00000000000000000000000000000000000000000000001000000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000100000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000010000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000001000000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000000100000: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000000010000: n1274 = n249;
      56'b00000000000000000000000000000000000000000000000000001000: n1274 = 40'b0100000000000000000000000000000000000000;
      56'b00000000000000000000000000000000000000000000000000000100: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000000000010: n1274 = 40'bX;
      56'b00000000000000000000000000000000000000000000000000000001: n1274 = 40'bX;
      default: n1274 = 40'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00100000000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1290 = n1094;
      56'b00001000000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000001000000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1290 = n820;
      56'b00000000000010000000000000000000000000000000000000000000: n1290 = n784;
      56'b00000000000001000000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000100000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000100000000000000000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000010000000000000000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000001000000000000000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000000100000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000000001000000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000001000000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000010000000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000001000000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000000000100000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000000000000001000000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000000000000000010000000000: n1290 = 1'b1;
      56'b00000000000000000000000000000000000000000000001000000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1290 = n252;
      56'b00000000000000000000000000000000000000000000000000001000: n1290 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000100: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1290 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1290 = 1'b0;
      default: n1290 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b01000000000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00100000000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00010000000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00001000000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000100000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000010000000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000001000000000000000000000000000000000000000000000000: n1293 = n929;
      56'b00000000100000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000010000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000001000000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000100000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000010000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000001000000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000100000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000010000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000001000000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000100000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000010000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000001000000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000100000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000010000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000001000000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000100000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000010000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000001000000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000100000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000010000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000001000000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000100000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000010000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000001000000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000100000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000010000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000001000000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000100000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000010000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000001000000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000100000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000010000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000001000000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000100000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000010000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000001000000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000100000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000010000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000001000000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000100000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000010000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000001000000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000100000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000010000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000001000: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000000100: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000000010: n1293 = data_in;
      56'b00000000000000000000000000000000000000000000000000000001: n1293 = data_in;
      default: n1293 = 8'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b01000000000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00100000000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00010000000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00001000000000000000000000000000000000000000000000000000: n1296 = 7'b0000000;
      56'b00000100000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000010000000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000001000000000000000000000000000000000000000000000000: n1296 = n930;
      56'b00000000100000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000010000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000001000000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000100000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000010000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000001000000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000100000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000010000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000001000000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000100000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000010000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000001000000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000100000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000010000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000001000000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000100000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000010000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000001000000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000100000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000010000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000001000000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000100000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000010000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000001000000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000100000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000010000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000001000000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000100000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000010000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000001000000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000100000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000010000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000001000000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000100000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000010000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000001000000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000100000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000010000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000001000000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000100000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000010000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000001000000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000100000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000010000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000001000: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000000100: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000000010: n1296 = crc7;
      56'b00000000000000000000000000000000000000000000000000000001: n1296 = crc7;
      default: n1296 = 7'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b01000000000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00100000000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00010000000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00001000000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000100000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000010000000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000001000000000000000000000000000000000000000000000000: n1299 = n931;
      56'b00000000100000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000010000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000001000000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000100000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000010000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000001000000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000100000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000010000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000001000000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000100000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000010000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000001000000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000100000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000010000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000001000000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000100000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000010000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000001000000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000100000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000010000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000001000000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000100000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000010000000000000000000000000: n1299 = 16'b0000000000000000;
      56'b00000000000000000000000000000001000000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000100000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000010000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000001000000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000100000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000010000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000001000000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000100000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000010000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000001000000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000100000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000010000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000001000000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000100000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000010000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000001000000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000100000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000010000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000001000000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000100000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000010000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000001000: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000000100: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000000010: n1299 = in_crc16;
      56'b00000000000000000000000000000000000000000000000000000001: n1299 = in_crc16;
      default: n1299 = 16'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b01000000000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00100000000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00010000000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00001000000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000100000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000010000000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000001000000000000000000000000000000000000000000000000: n1302 = n932;
      56'b00000000100000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000010000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000001000000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000100000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000010000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000001000000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000100000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000010000000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000001000000000000000000000000000000000000000: n1302 = 16'b0000000000000000;
      56'b00000000000000000100000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000010000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000001000000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000100000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000010000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000001000000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000100000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000010000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000001000000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000100000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000010000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000001000000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000100000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000010000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000001000000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000100000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000010000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000001000000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000100000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000010000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000001000000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000100000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000010000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000001000000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000100000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000010000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000001000000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000100000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000010000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000001000000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000100000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000010000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000001000000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000100000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000010000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000001000: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000000100: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000000010: n1302 = out_crc16;
      56'b00000000000000000000000000000000000000000000000000000001: n1302 = out_crc16;
      default: n1302 = 16'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b01000000000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00100000000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00010000000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00001000000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000100000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000010000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000001000000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000100000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000010000000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000001000000000000000000000000000000000000000000000: n1304 = n833;
      56'b00000000000100000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000010000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000001000000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000100000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000010000000000000000000000000000000000000000: n1304 = n719;
      56'b00000000000000001000000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000100000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000010000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000001000000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000100000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000010000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000001000000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000100000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000010000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000001000000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000100000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000010000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000001000000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000100000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000010000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000001000000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000100000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000010000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000001000000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000100000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000010000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000001000000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000100000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000010000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000001000000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000100000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000010000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000001000000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000100000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000010000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000001000000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000100000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000010000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000001000000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000100000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000010000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000001000: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000000100: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000000010: n1304 = crclow;
      56'b00000000000000000000000000000000000000000000000000000001: n1304 = crclow;
      default: n1304 = 8'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1309 = data_out;
      56'b01000000000000000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00100000000000000000000000000000000000000000000000000000: n1309 = n1099;
      56'b00010000000000000000000000000000000000000000000000000000: n1309 = n1095;
      56'b00001000000000000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000100000000000000000000000000000000000000000000000000: n1309 = 8'b11111111;
      56'b00000010000000000000000000000000000000000000000000000000: n1309 = n1061;
      56'b00000001000000000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000100000000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000010000000000000000000000000000000000000000000000: n1309 = n848;
      56'b00000000001000000000000000000000000000000000000000000000: n1309 = n835;
      56'b00000000000100000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000010000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000001000000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000100000000000000000000000000000000000000000: n1309 = crclow;
      56'b00000000000000010000000000000000000000000000000000000000: n1309 = n720;
      56'b00000000000000001000000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000100000000000000000000000000000000000000: n1309 = n680;
      56'b00000000000000000010000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000001000000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000100000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000010000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000001000000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000100000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000010000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000001000000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000100000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000010000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000001000000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000100000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000010000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000001000000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000100000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000010000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000001000000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000100000000000000000000: n1309 = 8'b11111111;
      56'b00000000000000000000000000000000000010000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000001000000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000100000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000010000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000001000000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000100000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000010000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000001000000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000100000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000010000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000001000000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000100000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000010000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000001000000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000000100000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000000010000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000000001000: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000000000100: n1309 = data_out;
      56'b00000000000000000000000000000000000000000000000000000010: n1309 = 8'b11111111;
      56'b00000000000000000000000000000000000000000000000000000001: n1309 = data_out;
      default: n1309 = 8'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b01000000000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00100000000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00010000000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00001000000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000100000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000010000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000001000000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000100000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000010000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000001000000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000100000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000010000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000001000000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000100000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000010000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000001000000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000100000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000010000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000001000000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000100000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000010000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000001000000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000100000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000010000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000001000000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000100000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000010000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000001000000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000100000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000010000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000001000000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000100000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000010000000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000001000000000000000000000: n1313 = n454;
      56'b00000000000000000000000000000000000100000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000010000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000001000000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000100000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000010000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000001000000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000100000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000010000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000001000000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000100000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000010000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000001000000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000100000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000010000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000001000000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000000100000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000000010000: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000000001000: n1313 = 32'b00000000000000000000000000000000;
      56'b00000000000000000000000000000000000000000000000000000100: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000000000010: n1313 = 32'bX;
      56'b00000000000000000000000000000000000000000000000000000001: n1313 = 32'bX;
      default: n1313 = 32'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b01000000000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00100000000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00010000000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00001000000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000100000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000010000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000001000000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000100000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000010000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000001000000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000100000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000010000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000001000000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000100000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000010000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000001000000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000100000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000010000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000001000000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000100000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000010000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000001000000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000100000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000010000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000001000000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000100000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000010000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000001000000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000100000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000010000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000001000000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000100000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000010000000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000001000000000000000000000: n1316 = n455;
      56'b00000000000000000000000000000000000100000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000010000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000001000000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000100000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000010000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000001000000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000100000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000010000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000001000000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000100000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000010000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000001000000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000100000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000010000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000001000000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000100000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000010000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000001000: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000000100: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000000010: n1316 = wr_erase_count;
      56'b00000000000000000000000000000000000000000000000000000001: n1316 = wr_erase_count;
      default: n1316 = 8'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00100000000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00001000000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000100000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000001000000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000001000000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000100000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000100000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000100000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000010000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000001000000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000100000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000001000000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000001000000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000010000000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000001000000000000000000000: n1320 = n457;
      56'b00000000000000000000000000000000000100000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000100000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000001000000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000010000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000001000000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000001000: n1320 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000100: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1320 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000001: n1320 = 1'b0;
      default: n1320 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b01000000000000000000000000000000000000000000000000000000: n1328 = 10'b0000001010;
      56'b00100000000000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00010000000000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00001000000000000000000000000000000000000000000000000000: n1328 = 10'b0000000101;
      56'b00000100000000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000010000000000000000000000000000000000000000000000000: n1328 = n1042;
      56'b00000001000000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000100000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000010000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000001000000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000100000000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000010000000000000000000000000000000000000000000: n1328 = n785;
      56'b00000000000001000000000000000000000000000000000000000000: n1328 = 10'b0000001010;
      56'b00000000000000100000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000010000000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000001000000000000000000000000000000000000000: n1328 = 10'b1000000000;
      56'b00000000000000000100000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000010000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000001000000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000100000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000010000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000001000000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000100000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000010000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000001000000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000100000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000010000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000001000000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000100000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000010000000000000000000000000: n1328 = n543;
      56'b00000000000000000000000000000001000000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000100000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000010000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000001000000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000100000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000010000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000001000000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000100000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000010000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000001000000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000100000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000010000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000001000000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000100000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000010000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000001000000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000100000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000010000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000001000000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000000100000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000000010000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000000001000: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000000000100: n1328 = byte_counter;
      56'b00000000000000000000000000000000000000000000000000000010: n1328 = 10'b0000010100;
      56'b00000000000000000000000000000000000000000000000000000001: n1328 = byte_counter;
      default: n1328 = 10'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b01000000000000000000000000000000000000000000000000000000: n1336 = 1'b1;
      56'b00100000000000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00010000000000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00001000000000000000000000000000000000000000000000000000: n1336 = 1'b1;
      56'b00000100000000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000010000000000000000000000000000000000000000000000000: n1336 = n1064;
      56'b00000001000000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000100000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000010000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000001000000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000100000000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000010000000000000000000000000000000000000000000: n1336 = n787;
      56'b00000000000001000000000000000000000000000000000000000000: n1336 = 1'b1;
      56'b00000000000000100000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000010000000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000001000000000000000000000000000000000000000: n1336 = 1'b1;
      56'b00000000000000000100000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000010000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000001000000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000100000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000010000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000001000000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000100000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000010000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000001000000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000100000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000010000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000001000000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000100000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000010000000000000000000000000: n1336 = n545;
      56'b00000000000000000000000000000001000000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000100000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000010000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000001000000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000100000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000001000000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000100000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000010000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000001000000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000100000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000010000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000001000000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000100000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000010000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000001000000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000100000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000010000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000001000000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000100000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000010000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000001000: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000100: n1336 = 1'b0;
      56'b00000000000000000000000000000000000000000000000000000010: n1336 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000001: n1336 = 1'b0;
      default: n1336 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b01000000000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00100000000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00010000000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00001000000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000100000000000000000000000000000000000000000000000000: n1341 = 8'b00000111;
      56'b00000010000000000000000000000000000000000000000000000000: n1341 = n1065;
      56'b00000001000000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000100000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000010000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000001000000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000100000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000010000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000001000000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000100000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000010000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000001000000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000100000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000010000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000001000000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000100000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000010000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000001000000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000100000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000010000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000001000000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000100000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000010000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000001000000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000100000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000010000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000001000000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000100000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000010000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000001000000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000100000000000000000000: n1341 = 8'b00000111;
      56'b00000000000000000000000000000000000010000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000001000000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000100000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000010000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000001000000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000100000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000010000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000001000000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000100000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000010000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000001000000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000100000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000010000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000001000000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000100000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000010000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000001000: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000000100: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000000010: n1341 = bit_counter;
      56'b00000000000000000000000000000000000000000000000000000001: n1341 = bit_counter;
      default: n1341 = 8'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b01000000000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00100000000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00010000000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00001000000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000100000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000010000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000001000000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000100000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000010000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000001000000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000100000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000010000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000001000000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000100000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000010000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000001000000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000100000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000010000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000001000000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000100000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000010000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000001000000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000100000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000010000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000001000000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000100000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000010000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000001000000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000100000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000010000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000001000000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000100000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000010000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000001000000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000100000000000000000000: n1345 = 1'b0;
      56'b00000000000000000000000000000000000010000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000001000000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000100000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000010000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000001000000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000100000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000010000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000001000000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000100000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000010000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000001000000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000100000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000010000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000001000000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000000100000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000000010000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000000001000: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000000000100: n1345 = slow_clock;
      56'b00000000000000000000000000000000000000000000000000000010: n1345 = 1'b1;
      56'b00000000000000000000000000000000000000000000000000000001: n1345 = slow_clock;
      default: n1345 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b01000000000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00100000000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00010000000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00001000000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000100000000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000010000000000000000000000000000000000000000000000000: n1348 = n1067;
      56'b00000001000000000000000000000000000000000000000000000000: n1348 = n934;
      56'b00000000100000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000010000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000001000000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000100000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000010000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000001000000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000100000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000010000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000001000000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000100000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000010000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000001000000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000100000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000010000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000001000000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000100000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000010000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000001000000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000100000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000010000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000001000000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000100000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000010000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000001000000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000100000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000010000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000001000000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000100000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000010000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000001000000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000100000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000010000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000001000000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000100000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000010000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000001000000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000100000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000010000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000001000000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000100000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000010000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000001000000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000000100000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000000010000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000000001000: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000000000100: n1348 = clock_divider;
      56'b00000000000000000000000000000000000000000000000000000010: n1348 = 7'b1000000;
      56'b00000000000000000000000000000000000000000000000000000001: n1348 = clock_divider;
      default: n1348 = 7'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b01000000000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00100000000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00010000000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00001000000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000100000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000010000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000001000000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000100000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000010000000000000000000000000000000000000000000000: n1350 = n850;
      56'b00000000001000000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000100000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000010000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000001000000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000100000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000010000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000001000000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000100000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000010000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000001000000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000100000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000010000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000001000000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000100000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000010000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000001000000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000100000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000010000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000001000000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000100000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000010000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000001000000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000100000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000010000000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000001000000000000000000000: n1350 = n458;
      56'b00000000000000000000000000000000000100000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000010000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000001000000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000100000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000010000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000001000000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000100000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000010000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000001000000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000100000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000010000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000001000000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000100000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000010000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000001000000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000100000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000010000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000001000: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000000100: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000000010: n1350 = multiple;
      56'b00000000000000000000000000000000000000000000000000000001: n1350 = multiple;
      default: n1350 = 1'bX;
    endcase
  /* sd_spi.vhd:423:17  */
  always @*
    case (n1130)
      56'b10000000000000000000000000000000000000000000000000000000: n1353 = n1127;
      56'b01000000000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00100000000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00010000000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00001000000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000100000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000010000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000001000000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000100000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000010000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000001000000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000100000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000010000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000001000000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000100000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000010000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000001000000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000100000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000010000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000001000000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000100000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000010000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000001000000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000100000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000010000000000000000000000000000000: n1353 = 1'b1;
      56'b00000000000000000000000001000000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000100000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000010000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000001000000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000100000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000010000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000001000000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000100000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000010000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000001000000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000100000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000010000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000001000000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000100000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000010000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000001000000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000100000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000010000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000001000000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000100000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000010000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000001000000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000100000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000010000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000001000000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000100000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000010000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000001000: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000000100: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000000010: n1353 = skipfirstr1byte;
      56'b00000000000000000000000000000000000000000000000000000001: n1353 = skipfirstr1byte;
      default: n1353 = 1'bX;
    endcase
  /* sd_spi.vhd:1111:31  */
  assign n1357 = state == 6'b000000;
  /* sd_spi.vhd:1112:31  */
  assign n1360 = state == 6'b000001;
  /* sd_spi.vhd:1113:31  */
  assign n1363 = state == 6'b000010;
  /* sd_spi.vhd:1114:31  */
  assign n1366 = state == 6'b000011;
  /* sd_spi.vhd:1115:31  */
  assign n1369 = state == 6'b000100;
  /* sd_spi.vhd:1116:31  */
  assign n1372 = state == 6'b000101;
  /* sd_spi.vhd:1117:31  */
  assign n1375 = state == 6'b000110;
  /* sd_spi.vhd:1118:31  */
  assign n1378 = state == 6'b000111;
  /* sd_spi.vhd:1119:31  */
  assign n1381 = state == 6'b001000;
  /* sd_spi.vhd:1120:31  */
  assign n1384 = state == 6'b001001;
  /* sd_spi.vhd:1121:31  */
  assign n1387 = state == 6'b001010;
  /* sd_spi.vhd:1122:31  */
  assign n1390 = state == 6'b001011;
  /* sd_spi.vhd:1123:31  */
  assign n1393 = state == 6'b001100;
  /* sd_spi.vhd:1124:31  */
  assign n1396 = state == 6'b001101;
  /* sd_spi.vhd:1125:31  */
  assign n1399 = state == 6'b001110;
  /* sd_spi.vhd:1126:31  */
  assign n1402 = state == 6'b001111;
  /* sd_spi.vhd:1127:31  */
  assign n1405 = state == 6'b010000;
  /* sd_spi.vhd:1128:31  */
  assign n1408 = state == 6'b010001;
  /* sd_spi.vhd:1129:31  */
  assign n1411 = state == 6'b010010;
  /* sd_spi.vhd:1130:31  */
  assign n1414 = state == 6'b010011;
  /* sd_spi.vhd:1131:31  */
  assign n1417 = state == 6'b010100;
  /* sd_spi.vhd:1132:31  */
  assign n1420 = state == 6'b010101;
  /* sd_spi.vhd:1133:31  */
  assign n1423 = state == 6'b010110;
  /* sd_spi.vhd:1134:31  */
  assign n1426 = state == 6'b010111;
  /* sd_spi.vhd:1135:31  */
  assign n1429 = state == 6'b011000;
  /* sd_spi.vhd:1136:31  */
  assign n1432 = state == 6'b011001;
  /* sd_spi.vhd:1137:31  */
  assign n1435 = state == 6'b011010;
  /* sd_spi.vhd:1138:31  */
  assign n1438 = state == 6'b011011;
  /* sd_spi.vhd:1139:31  */
  assign n1441 = state == 6'b011100;
  /* sd_spi.vhd:1140:31  */
  assign n1444 = state == 6'b011101;
  /* sd_spi.vhd:1141:31  */
  assign n1447 = state == 6'b011110;
  /* sd_spi.vhd:1142:31  */
  assign n1450 = state == 6'b011111;
  /* sd_spi.vhd:1143:31  */
  assign n1453 = state == 6'b100000;
  /* sd_spi.vhd:1144:31  */
  assign n1456 = state == 6'b100001;
  /* sd_spi.vhd:1145:31  */
  assign n1459 = state == 6'b100010;
  /* sd_spi.vhd:1146:31  */
  assign n1462 = state == 6'b100011;
  /* sd_spi.vhd:1147:31  */
  assign n1465 = state == 6'b100100;
  /* sd_spi.vhd:1148:31  */
  assign n1468 = state == 6'b100101;
  /* sd_spi.vhd:1149:31  */
  assign n1471 = state == 6'b100110;
  /* sd_spi.vhd:1150:31  */
  assign n1474 = state == 6'b100111;
  /* sd_spi.vhd:1151:31  */
  assign n1477 = state == 6'b101000;
  /* sd_spi.vhd:1152:31  */
  assign n1480 = state == 6'b101001;
  /* sd_spi.vhd:1153:31  */
  assign n1483 = state == 6'b101010;
  /* sd_spi.vhd:1154:31  */
  assign n1486 = state == 6'b101011;
  /* sd_spi.vhd:1155:31  */
  assign n1489 = state == 6'b101100;
  /* sd_spi.vhd:1156:31  */
  assign n1492 = state == 6'b101101;
  /* sd_spi.vhd:1157:31  */
  assign n1495 = state == 6'b110000;
  /* sd_spi.vhd:1158:31  */
  assign n1498 = state == 6'b101110;
  /* sd_spi.vhd:1159:31  */
  assign n1501 = state == 6'b101111;
  /* sd_spi.vhd:1160:31  */
  assign n1504 = state == 6'b110001;
  /* sd_spi.vhd:1161:31  */
  assign n1507 = state == 6'b110010;
  /* sd_spi.vhd:1162:31  */
  assign n1510 = state == 6'b110011;
  /* sd_spi.vhd:1163:31  */
  assign n1513 = state == 6'b110100;
  /* sd_spi.vhd:1164:31  */
  assign n1516 = state == 6'b110101;
  /* sd_spi.vhd:1165:31  */
  assign n1519 = state == 6'b110110;
  /* sd_spi.vhd:1166:31  */
  assign n1522 = state == 6'b110111;
  /* sd_spi.vhd:1110:17  */
  assign n1523 = {n1522, n1519, n1516, n1513, n1510, n1507, n1504, n1501, n1498, n1495, n1492, n1489, n1486, n1483, n1480, n1477, n1474, n1471, n1468, n1465, n1462, n1459, n1456, n1453, n1450, n1447, n1444, n1441, n1438, n1435, n1432, n1429, n1426, n1423, n1420, n1417, n1414, n1411, n1408, n1405, n1402, n1399, n1396, n1393, n1390, n1387, n1384, n1381, n1378, n1375, n1372, n1369, n1366, n1363, n1360, n1357};
  /* sd_spi.vhd:1110:17  */
  always @*
    case (n1523)
      56'b10000000000000000000000000000000000000000000000000000000: n1525 = 8'b01001110;
      56'b01000000000000000000000000000000000000000000000000000000: n1525 = 8'b01001101;
      56'b00100000000000000000000000000000000000000000000000000000: n1525 = 8'b01001100;
      56'b00010000000000000000000000000000000000000000000000000000: n1525 = 8'b01001011;
      56'b00001000000000000000000000000000000000000000000000000000: n1525 = 8'b01001010;
      56'b00000100000000000000000000000000000000000000000000000000: n1525 = 8'b01001001;
      56'b00000010000000000000000000000000000000000000000000000000: n1525 = 8'b01001000;
      56'b00000001000000000000000000000000000000000000000000000000: n1525 = 8'b01000111;
      56'b00000000100000000000000000000000000000000000000000000000: n1525 = 8'b01000110;
      56'b00000000010000000000000000000000000000000000000000000000: n1525 = 8'b01000101;
      56'b00000000001000000000000000000000000000000000000000000000: n1525 = 8'b01000100;
      56'b00000000000100000000000000000000000000000000000000000000: n1525 = 8'b01000011;
      56'b00000000000010000000000000000000000000000000000000000000: n1525 = 8'b01000010;
      56'b00000000000001000000000000000000000000000000000000000000: n1525 = 8'b01000001;
      56'b00000000000000100000000000000000000000000000000000000000: n1525 = 8'b01000000;
      56'b00000000000000010000000000000000000000000000000000000000: n1525 = 8'b00110111;
      56'b00000000000000001000000000000000000000000000000000000000: n1525 = 8'b00110110;
      56'b00000000000000000100000000000000000000000000000000000000: n1525 = 8'b00110101;
      56'b00000000000000000010000000000000000000000000000000000000: n1525 = 8'b00110100;
      56'b00000000000000000001000000000000000000000000000000000000: n1525 = 8'b00110011;
      56'b00000000000000000000100000000000000000000000000000000000: n1525 = 8'b00110010;
      56'b00000000000000000000010000000000000000000000000000000000: n1525 = 8'b00110001;
      56'b00000000000000000000001000000000000000000000000000000000: n1525 = 8'b00110000;
      56'b00000000000000000000000100000000000000000000000000000000: n1525 = 8'b00101001;
      56'b00000000000000000000000010000000000000000000000000000000: n1525 = 8'b00101000;
      56'b00000000000000000000000001000000000000000000000000000000: n1525 = 8'b00100111;
      56'b00000000000000000000000000100000000000000000000000000000: n1525 = 8'b00100110;
      56'b00000000000000000000000000010000000000000000000000000000: n1525 = 8'b00100101;
      56'b00000000000000000000000000001000000000000000000000000000: n1525 = 8'b00100100;
      56'b00000000000000000000000000000100000000000000000000000000: n1525 = 8'b00100011;
      56'b00000000000000000000000000000010000000000000000000000000: n1525 = 8'b00100010;
      56'b00000000000000000000000000000001000000000000000000000000: n1525 = 8'b00100001;
      56'b00000000000000000000000000000000100000000000000000000000: n1525 = 8'b00100000;
      56'b00000000000000000000000000000000010000000000000000000000: n1525 = 8'b00100000;
      56'b00000000000000000000000000000000001000000000000000000000: n1525 = 8'b00010001;
      56'b00000000000000000000000000000000000100000000000000000000: n1525 = 8'b00010000;
      56'b00000000000000000000000000000000000010000000000000000000: n1525 = 8'b00001010;
      56'b00000000000000000000000000000000000001000000000000000000: n1525 = 8'b00001001;
      56'b00000000000000000000000000000000000000100000000000000000: n1525 = 8'b00001000;
      56'b00000000000000000000000000000000000000010000000000000000: n1525 = 8'b00001000;
      56'b00000000000000000000000000000000000000001000000000000000: n1525 = 8'b00001000;
      56'b00000000000000000000000000000000000000000100000000000000: n1525 = 8'b00001000;
      56'b00000000000000000000000000000000000000000010000000000000: n1525 = 8'b00001000;
      56'b00000000000000000000000000000000000000000001000000000000: n1525 = 8'b00000111;
      56'b00000000000000000000000000000000000000000000100000000000: n1525 = 8'b00000110;
      56'b00000000000000000000000000000000000000000000010000000000: n1525 = 8'b00000101;
      56'b00000000000000000000000000000000000000000000001000000000: n1525 = 8'b00000100;
      56'b00000000000000000000000000000000000000000000000100000000: n1525 = 8'b00000100;
      56'b00000000000000000000000000000000000000000000000010000000: n1525 = 8'b00000100;
      56'b00000000000000000000000000000000000000000000000001000000: n1525 = 8'b00000100;
      56'b00000000000000000000000000000000000000000000000000100000: n1525 = 8'b00000100;
      56'b00000000000000000000000000000000000000000000000000010000: n1525 = 8'b00000011;
      56'b00000000000000000000000000000000000000000000000000001000: n1525 = 8'b00000010;
      56'b00000000000000000000000000000000000000000000000000000100: n1525 = 8'b00000001;
      56'b00000000000000000000000000000000000000000000000000000010: n1525 = 8'b00000000;
      56'b00000000000000000000000000000000000000000000000000000001: n1525 = 8'b00000000;
      default: n1525 = 8'bX;
    endcase
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1526 <= n102;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1527 <= n104;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1528 <= n106;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1529 <= n108;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1530 <= n110;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1531 <= n112;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1532 <= n114;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1533 <= n116;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1534 <= n118;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1535 <= n120;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1536 <= n122;
  initial
    n1536 = 6'b000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1537 <= n124;
  initial
    n1537 = 6'b000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1538 <= n126;
  initial
    n1538 = 6'b000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1539 <= n128;
  initial
    n1539 = 1'b1;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1540 <= n130;
  initial
    n1540 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1541 <= n132;
  initial
    n1541 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1542 <= n134;
  initial
    n1542 = 2'b00;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1543 <= n136;
  initial
    n1543 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1544 <= n138;
  initial
    n1544 = 3'b000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1545 <= n140;
  initial
    n1545 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1546 <= n142;
  initial
    n1546 = 40'b1111111111111111111111111111111111111111;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1547 <= n144;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1548 <= n146;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1549 <= n148;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1550 <= n150;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1551 <= n152;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1552 <= n154;
  initial
    n1552 = 8'b00000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1553 <= n156;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1554 <= n158;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1555 <= n160;
  initial
    n1555 = 10'b0000000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1556 <= n162;
  initial
    n1556 = 8'b00000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1557 <= n164;
  initial
    n1557 = 1'b1;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1558 <= n166;
  initial
    n1558 = 7'b0000000;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1559 <= n168;
  initial
    n1559 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1560 <= n170;
  initial
    n1560 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1561 <= n171;
  initial
    n1561 = 1'b0;
  /* sd_spi.vhd:269:17  */
  always @(posedge clk)
    n1562 <= n172;
  initial
    n1562 = 1'b0;
endmodule

