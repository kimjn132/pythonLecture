"""
Create on 2023-02-09
author : anna
Description : gps lat, lng값 보내기
"""

from flask import Flask, jsonify, request

# map
import folium

# csv파일 불러오기
import pandas as pd

# 좌표->주소 변환
from geopy.geocoders import Nominatim
    
# 경로 위치 함수
import os


# 어플과 연결
app = Flask(__name__)


@app.route("/vieweb")
def gps():
    try:
        # app에서 사용자 gps로 받은 위도 경도 값 갖고오기
        latitude = float(request.args.get("latitude"))
        longitude = float(request.args.get("longitude"))
        
        
        # 파일 경로 위치 찾아주기
        wh_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./wh.csv")
        wh_address_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./wh_address.csv")
        
        
        
        # 해당 경로 위치로 데이터 불러오기
        wh = pd.read_csv(wh_path, index_col=0)
        wh_address = pd.read_csv(wh_address_path, index_col=0)
        wh_html = os.path.join(os.path.dirname(os.path.abspath(__file__)), "./seoul_hos.html")

        # 사용자 좌표값 주소로 변환
        geolocoder = Nominatim(user_agent = 'South Korea', timeout=None)
        address = geolocoder.reverse(f"{latitude}, {longitude}")
        
        # 사용자 좌표값을 주소로 변환한 후 그 주소에서 '구'가 포함된 글자만 추출 (예시: '강남구')
        gu = [ad for ad in address[0].split(", ") if "구" in ad]
        
        # wh_address['주소']에서 gu 값이 포함된 wh에서의 주소와 위도 경도 모두 추출(병원 정보 데이터)
        myloc = wh[wh_address['주소'].str.contains(gu[0])]
        print(gu[0])
        
        # 1. MAP 만들기
        seoul_hos = folium.Map(
        # 내 위치 (사용자에게 받은 위도 경도값)
        location=[latitude,longitude],
        tiles= 'Stamen Terrain', 
        zoom_start=14, 
        )

        # 병원 위치정보를 Marker로 지도에 표시
        for add, name, tel, lat, lng in zip(myloc.주소, myloc.기관명, myloc.대표전화, myloc.병원위도, myloc.병원경도):
                html = """
                    <style>
                        .section-title {
                            font-size: 36px;
                            font-weight: bold;
                            text-transform: uppercase;
                            letter-spacing: 2px;
                            color: #ff66cc;
                            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                            }
                        .section-content {
                            background: linear-gradient(to bottom, #fff, #f1f1f1);
                            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
                            padding: 15px;
                            position: relative;
                            }
                        .section-content p {
                            font-size: 13px;
                            line-height: 1.5;
                            }
                        @media (max-width: 768px) {
                        .section-content {
                                padding: 5px;
                            }
                        }
                    </style>
                    <div class="section-title">
                        <h5>%s</h5>
                    </div>
                    <div class="section-content">
                        <p>
                            <b>주소: </b> %s<br>
                            <b>tel: </b><a href="tel:%s">%s</a><br>
                        </p>
                    </div>
                    """% (name, add, tel, tel)
    
                folium.Marker([lat, lng],
                            popup=folium.Popup(html, max_width=300),
                            popup_orientation='horizontal',
                            icon=folium.Icon(color='blue', icon='medkit', prefix='fa'),
                            title=name,
                            ).add_to(seoul_hos)


        # 기존의 마커와 모양이 다르다. CircleMarker는 범위를 주어서 사용할 수 있는 마커이다.
        # 대학교 위치정보를 CircleMarker로 표시
        for name, lat, lng in zip(myloc.기관명, myloc.병원위도, myloc.병원경도):
            folium.CircleMarker([lat, lng],
                                radius=5, # radius 는 원의 반지름 크기이다.
                                color = 'orange', # 원 둘레의 색상
                                fill=False, # 칼라를 채우겠냐 채우지 않겠냐. (원형안의 색상)
                                # fill_color='coral', # 원형마커의 색상(원을 채우는 색)
                                # fill_opacity = 0.7, # 원형의 투명도 1은 완전한 불투명이다.
                                popup=name,
                                ).add_to(seoul_hos)
                    
        # 사용자 gps 위치에 해당되는 '구' 지역의 병원 마커 찍은 지도 저장
        seoul_hos.save(wh_html)
        
        return str(seoul_hos)
    
    except Exception as e:
         # handle the exception and return an appropriate response
        return jsonify({"error": str(e)})



if __name__ == "__main__":
    app.run(host="172.20.10.5", port=5000, debug=True)
    
    